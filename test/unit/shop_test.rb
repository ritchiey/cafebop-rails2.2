require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase

  context "a shop" do
    setup do
      @shop = Shop.make
    end                
    
    should "default to community managed" do
      assert @shop.community?
      assert !@shop.express?
      assert !@shop.professional?
    end
    
    should "switch to express when told" do
      assert @shop.community?
      @shop.go_express!
      assert @shop.express?
    end

    should "switch to professional when told" do
      assert @shop.community?
      @shop.go_professional!
      assert @shop.professional?
    end

    should "get certain menu items when add_generic_cafe_menus is called" do
      @shop.add_generic_cafe_menus
      assert_not_nil(menu = @shop.menus.find_by_name('Drinks'))
      assert_not_nil(coffee = menu.menu_items.find_by_name('Coffee'))
      assert_not_nil(large = coffee.sizes.find_by_name('Large'))
      assert_equal "4.50", large.price
    end     
    
    context "with a given cuisine" do
      setup do
        @cuisine = Cuisine.make
        @shop.cuisines << @cuisine
      end                        
      
      should "appear to have that cuisine"  do
        assert_equal [@cuisine], @shop.cuisines.all
      end                                          
      
      should "appear in the list of shops with_cuisine(@cuisine)" do
        other_shop = Shop.make
        assert_equal [@shop], Shop.with_cuisine(@cuisine)
      end
      
      should "appear in a search for that shop with that cuisine" do
        search = Search.new(:cuisine=>@cuisine.id.to_s, :term=>@shop.name)
        assert_equal [@shop], search.shops 
      end
      
      should "not appear in a search for that shop name but a different cuisine" do
        search = Search.new(:cuisine=>Cuisine.make.id.to_s, :term=>@shop.name)
        assert_equal [], search.shops
      end
      
    end
       
  end
   
  context "a community shop " do
    setup do
      @shop = Shop.make
      assert @shop.community?
    end       
    
    should "only be claimable by a an appropriate user" do
      user = User.make
      assert @shop.can_be_claimed_by?(user) 
      assert @shop.claims.create(:user=>user)  
      @shop.reload
      user.reload
      assert !@shop.can_be_claimed_by?(user)
      claim = @shop.claims.build(:user=>user)
      assert !claim.save
    end

    context "with a given cuisine" do
      setup do
        @cuisine = Cuisine.make
        @menu = Menu.make(:shop=>nil, :cuisine=>@cuisine)
      end
    end
    
    context "with some menus and menu_items" do
      setup do
        for i in (1..3)  
          menu = Menu.make({:shop=>@shop})
          for j in (1..2)
            MenuItem.make({:menu=>menu})
          end
        end
      end

      should "see the correct number of items in shop.menu_items" do
        assert_equal 6, @shop.menu_items.count
      end                                     
    
      should "create a default queue and assign all current menu_items to it on go_express!" do
        assert @shop.item_queues.empty?
        @shop.go_express!
        queue = @shop.item_queues.find(:first)
        assert_not_nil queue
        assert_equal 6, queue.menu_items.length
      end
    
      context "being destroyed" do
        setup do
          @shop.destroy
        end

        should_change "Menu.count", :from=>3, :to=>0
        should_change "MenuItem.count", :from=>6, :to=>0
      end
    end
  end
end

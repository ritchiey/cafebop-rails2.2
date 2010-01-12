require File.dirname(__FILE__) + '/../test_helper'

class ShopTest < ActiveSupport::TestCase

  
  context "a shop" do
    setup do
      @shop = Shop.make
    end   
    
    should "not have a paypal recipient by default" do
      assert_nil @shop.paypal_recipient
    end             
    
    should "not be able to enable queuing" do
      assert !@shop.accepts_queued_orders?
      @shop.start_accepting_queued_orders!
      @shop.reload
      assert !@shop.accepts_queued_orders?
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
      assert @shop.claims.make(:user=>user)  
      @shop.reload
      user.reload
      assert !@shop.can_be_claimed_by?(user)
      claim = @shop.claims.make_unsaved(:user=>user)
      assert !claim.save
    end

    context "with a given cuisine" do
      setup do
        @cuisine = Cuisine.make(:name=>"Chicken")
        @shop.cuisines << @cuisine
        @menu = Menu.make(:name=>"Roast Chicken", :shop=>nil, :cuisines=>[@cuisine])
        assert_equal [@menu], @cuisine.menus.all
        assert_equal [@shop], @cuisine.shops
      end

      should "see the menus for that cuisine as virtual_menus" do
        assert_equal [@menu], Menu.virtual_for_shop(@shop)
        assert_equal [@menu], @shop.effective_menus
      end

      should "not have any menus" do
        assert @shop.menus.empty?
      end

      context "which goes express" do
        setup do
          @shop.go_express!
          @shop.reload
        end

        should "get a copy of the virtual menus" do
          assert_equal @shop.virtual_menus.*.name, @shop.menus.*.name
          assert_not_equal @shop.virtual_menus.*.id, @shop.menus.*.id
        end
        
        should "be able to enable queuing" do
          assert !@shop.accepts_queued_orders?
          @shop.start_accepting_queued_orders!
          @shop.reload
          assert @shop.accepts_queued_orders?
        end

        should "not be able to enable paypal because queues aren't enabled" do
          assert !@shop.accepts_queued_orders?
          assert !@shop.accepts_paypal_payments?
          @shop.enable_paypal_payments!
          @shop.reload
          assert !@shop.accepts_paypal_payments?
        end

        
        
      end
    end
    
  end
end

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
      
  end
   
  context "a community shop with some menus and menu_items" do
    setup do
      @shop = Shop.make
      assert @shop.community?
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
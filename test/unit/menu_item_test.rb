require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase
  
  context "a given menu_item" do
    
    setup do
      @item = MenuItem.make
    end
    
    should "parse a price correctly" do
      @item.price = "5.12"
      assert_equal 512, @item.price_in_cents
    end

    should "format its price correctly" do
      @item.price_in_cents = 1024
      assert_equal "10.24", @item.price
    end
    
  end
  
  context "a menu_item created in a shop with a queue" do
    setup do
      @shop = Shop.make
      @queue = @shop.item_queues.create(:name=>"Default Queue")
      @menu = Menu.make(:shop=>@shop)
      @menu_item = @menu.menu_items.create(:menu=>@menu, :name=>'Fish')
      assert_equal @shop, @menu_item.shop
      assert !@shop.item_queues.empty?
    end

    should "pickup the first queue in the shop" do
      assert !@menu_item.shop.item_queues.empty? 
      @menu_item.reload
      assert_equal @queue, @menu_item.item_queue
    end
    
  end
end
require File.dirname(__FILE__) + '/../test_helper'

class ItemQueueTest < ActiveSupport::TestCase

  context "an item_queue" do
    
    setup do
      @shop = Shop.make
      @queue = ItemQueue.make(:shop=>@shop)
      @menu = Menu.make(:shop=>@shop)
      @menu_item = MenuItem.make(:menu=>@menu, :item_queue=>@queue)
      @order_item = OrderItem.make(:menu_item=>@menu_item)
      assert_equal @queue, @order_item.item_queue
    end
    
    should "only see confirmed items in its current_items list" do
      assert @queue.current_items.empty?
      @order_item.confirm!
      assert @order_item.confirmed?    
      @order_item.save!
      assert_same_elements [@order_item], @queue.current_items.find(:all)
    end
    
  end
end
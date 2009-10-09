require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase

  context "an order_item" do
    
    setup do
      @item = OrderItem.make
    end
    
    should "default to pending" do
      assert @item.pending?
    end                    

    should "become printed when printed" do
      assert @item.pending?
      @item.print!
      assert @item.printed?
    end
    
    should "become queued when queued" do
      assert @item.pending?
      @item.queue!
      assert @item.queued?
    end

    should "become made from make!" do
      @item.queue!
      assert !@item.made?
      @item.make!
      assert @item.made?
    end
    
    should "adopt the item_queue of its menu_item" do
      assert_equal @item.menu_item.item_queue, @item.item_queue
    end

  end

end

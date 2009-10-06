require 'test_helper'

class OrderItemTest < ActiveSupport::TestCase

  context "a given order_item" do
    
    setup do
      @item = OrderItem.make
    end
    
    should "default to pending" do
      assert @item.pending?
    end                    

    should "become confirmed when confirmed" do
      assert !@item.confirmed?
      @item.confirm!
      assert @item.confirmed?
    end
    
    should "adopt the item_queue of its menu_item" do
      assert_equal @item.menu_item.item_queue, @item.item_queue
    end

  end

end

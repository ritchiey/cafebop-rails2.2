require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  
  context "a new order" do
    
    setup do
      @order = Order.make
    end                  
    
    should "default to pending" do
      assert_equal "pending", @order.state
    end                                   
    
    should "have no order_items" do
      assert @order.order_items.empty?
    end
    
    should "not be pending after confirm" do
      assert @order.pending?
      @order.confirm!
      assert !@order.pending?
      assert @order.confirmed?
    end
  end
  
  context "an order with a few order_items" do
    
    setup do
      @order = Order.make
      (1..3).each do |i|
        menu_item = MenuItem.make(:price_in_cents=>100)
        OrderItem.make(:order=>@order, :quantity=>i, :menu_item=>menu_item)
      end
      assert_equal 3, @order.order_items.length
    end
    
    should "calculate total correctly" do
      assert_equal 6.00, @order.total
    end

    should "confirm all its order_items when confirmed" do
      @order.order_items.each {|item| assert item.pending?}
      @order.confirm!
      assert @order.confirmed?
      @order.order_items.each {|item| assert item.confirmed?}
    end

  end
  
end

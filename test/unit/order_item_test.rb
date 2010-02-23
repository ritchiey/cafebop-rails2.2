require File.dirname(__FILE__) + '/../test_helper'

class OrderItemTest < ActiveSupport::TestCase

  context "a couple of order items" do
    setup do
      @order_items = (1..3).map {|n| OrderItem.make}
    end
    
    context "where 2 have the same description" do
      setup do
        [0, 2].each do |i|
          @order_items[i].stubs(:quantity).returns(2)
          @order_items[i].stubs(:description).returns("same again")
          @order_items[i].stubs(:price_in_cents).returns(500)
          @order_items[i].stubs(:notes).returns(nil)
          @order_items[i].stubs(:state).returns(:pending)
        end
      end

      should "summarize down to two order items" do
        summarized = OrderItem.summarize(@order_items)
        assert_equal 2, summarized.length
      end
    end
    

  end
  

  context "order_item associations" do      
    subject {OrderItem.make}      
    should_belong_to :item_queue
    should_belong_to :order
    should_belong_to :menu_item
    should_belong_to :size
    should_belong_to :flavour
  end

  context "an order_item" do

    setup do
      @item = OrderItem.make
    end      
    
    subject {@item}

    should_allow_values_for :state, *OrderItem::STATES
    should_validate_numericality_of :quantity

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

    should "be valid" do
      assert_valid @item
    end

    should "adopt the item_queue of its menu_item" do
      assert_equal @item.menu_item.item_queue, @item.item_queue
    end                       
    
    should "adopt the price_in_cents of its menu_item or size" do
      assert_equal @item.menu_item.price_in_cents, @item.price_in_cents
    end
    
#    should "have a valid state" do
#      assert @item.respond_to?("#{@item.state}?")# An item must have a valid state
#      assert_valid @item
#    end

#    should "have a quantity greater than 0" do
#      assert_operator @item.quantity, :>, 0
#      assert_valid @item
#    end    

    context "with invalid data" do 
      
      subject {@item}  

      should_not_allow_values_for :state, BasicForgery.text, BasicForgery.text
      should_not_allow_values_for :quantity, BasicForgery.number(:at_least => -25, :at_most => 0), nil
      should_not_allow_values_for :price_in_cents, BasicForgery.number(:at_least => -4500, :at_most => 0), nil

#      should "not validate a unknown state" do
#        @item.state = BasicForgery.text#
#        assert !OrderItem::STATES.include?(@item.state)# An item must have a valid state
#        @item.valid?
#        assert_contains @item.errors.full_messages, "#{'OrderItem'.tableize.humanize} #{'state'.humanize} #{default_error_message(:inclusion)}"#
#      end

#      matcher = allow_value(1).for(:quantity).with_message('is minimum 1')
#      should "not #{matcher.description}" do
#        assert_rejects matcher, subject
#      end
    end

  end

end

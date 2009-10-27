require File.dirname(__FILE__) + '/../test_helper'

class OrderItemTest < ActiveSupport::TestCase

  context "order_item associations" do
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

    should_allow_values_for :state, *OrderItem::STATES

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
    
#    should "have a valid state" do
#      assert @item.respond_to?("#{@item.state}?")# An item must have a valid state
#      assert_valid @item
#    end

#    should "have a quantity greater than 0" do
#      assert_operator @item.quantity, :>, 0
#      assert_valid @item
#    end    

    context "with invalid data" do

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

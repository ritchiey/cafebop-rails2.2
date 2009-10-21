require 'test_helper'

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

    should_validate_presence_of :state


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

    should "have a valid state" do
      assert @item.respond_to?("#{@item.state}?")# An item must have a valid state
      assert_valid @item
    end

    should "have a quantity greater than 0" do
      assert_operator @item.quantity, :>, 0
      assert_valid @item
    end

    should "have a positive price_in_cents" do
      assert_operator @item.price_in_cents, :>, 0
      assert_valid @item
    end

    should "adopt the item_queue of its menu_item" do
      assert_equal @item.menu_item.item_queue, @item.item_queue
    end

    context "with invalid data" do
      
      should "not validate a unknown state" do
        @item.state = BasicForgery.text
        
        assert !@item.respond_to?("#{@item.state}?")# An item must have a valid state
        assert !@item.valid?
      end

      should "not validate a quantity less than 1" do
        @item.quantity = BasicForgery.number(:at_least => -25, :at_most => 0)
        
        assert_operator @item.quantity, :<, 1
        assert !@item.valid?# An item must have a quantity greater than 0
      end

      should "not validate a negative price_in_cents" do
        @item.price_in_cents = BasicForgery.number(:at_least => -4500, :at_most => 0)
        
        assert_operator @item.price_in_cents, :<=, 0
        assert !@item.valid?# An item must have a price_in_cents greater than 0
        @item.price_in_cents = nil
        assert !@item.valid?# An item can't be nil
      end

    end

  end

end

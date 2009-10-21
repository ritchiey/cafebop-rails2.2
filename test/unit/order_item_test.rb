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

    should "adopt the item_queue of its menu_item" do
      assert_equal @item.menu_item.item_queue, @item.item_queue
    end

    should "have a valid state" do
      assert @item.send("#{@item.state}?")# An item must have a valid state
    end

    should "have a positive quantity" do
      assert_operator @item.quantity, :>, 0
      @item.quantity = 0
      assert !@item.valid?# An item must have a quantity greater than 0
      @item.quantity = BasicForgery.number :at_least => 1
      assert_valid @item
    end

    should "have a positive price_in_cents" do
      assert_operator @item.price_in_cents, :>, 0
      @item.price_in_cents = 0
      assert !@item.valid?# An item must have a price_in_cents greater than 0
      @item.price_in_cents = nil
      assert_valid @item# An item can be nil
      @item.price_in_cents = BasicForgery.number :at_least => 0.01
      assert_valid @item
    end

  end

end

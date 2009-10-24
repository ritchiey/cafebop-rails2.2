require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase

  context "menu_item associations" do
    should_have_many :flavours, :dependent => :destroy
    should_have_many :sizes, :dependent => :destroy
    should_have_many :order_items, :dependent => :nullify

    should_belong_to :item_queue
    should_belong_to :menu
  end
  
  context "a given menu_item" do

    setup do
      @item = MenuItem.make
    end
    
    should_ensure_length_at_least :name, 1
    
    should "parse a price correctly" do
      @item.price = "5.12"
      assert_equal 512, @item.price_in_cents
    end

    should "format its price correctly" do
      @item.price_in_cents = 1024
      assert_equal "10.24", @item.price
    end
    
    should "have a positive price_in_cents" do
      assert_operator @item.price_in_cents, :>, 0
      assert_valid @item
      @item.price_in_cents = nil
      assert_valid @item# An item can be nil
      @item.reload
    end
    
    context "with invalid data" do
      
      should "not validate a negative price_in_cents" do
        @item.price_in_cents = BasicForgery.number(:at_least => -4500, :at_most => 0)
        
        assert_operator @item.price_in_cents, :<=, 0
        assert !@item.valid?# An item must have a price_in_cents greater than 0
      end

    end

  end

  context "a menu_item created in a shop with a queue" do
    setup do
      @shop = Shop.make
      @queue = @shop.item_queues.create(:name=>"Default Queue")
      @menu = Menu.make(:shop=>@shop)
      @menu_item = @menu.menu_items.create(:menu=>@menu, :name=>'Fish')
      assert_equal @queue, @menu_item.item_queue     
      assert @menu_item.valid?
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

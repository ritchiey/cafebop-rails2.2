require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase

  context "menu_item associations" do
    should_have_many :flavours, :dependent => :destroy
    should_have_many :sizes, :dependent => :destroy
    should_have_many :order_items, :dependent => :nullify

    should_belong_to :item_queue
    should_belong_to :menu
  end

  context "a mock menu_item" do
    
    setup do
      @menu_item = MenuItem.new(:id=>1)
      @menu = Menu.new(:id=>2)
      @menu_item.stubs('menu').returns(@menu)
      @user = User.new
    end
    
    should "recognise non-manager" do
      @menu.expects('managed_by?').returns(false)
      assert !@menu_item.managed_by?(@user)
    end

    should "recognise manager" do
      @menu.expects('managed_by?').returns(true)
      assert @menu_item.managed_by?(@user)
    end

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

    should_allow_values_for :price_in_cents, nil

    should "be valid" do
      assert_valid @item
    end

    context "with invalid data" do
      should_not_allow_values_for :price_in_cents, BasicForgery.number(:at_least => -4500, :at_most => 0)
    end

    context "with a list of sizes" do
      setup do               
        @prices = "regular:$4.20, large:8.00 huge:20"
      end
      
      should "parse the list into price attributes" do
        price_attributes = @item.send :parse_prices, @prices
        assert_equal [
          {:name=>'regular', :price=>'4.20', :position=>1},
          {:name=>'large', :price=>'8.00', :position=>2},
          {:name=>'huge', :price=>'20', :position=>3} 
          ], price_attributes
      end            
      
      context "in the price field" do
        setup do               
          @item.price = @prices
          @item.save!
        end
        should "create the prices as sizes and reformat them" do
          assert_equal 3, @item.sizes.count
          assert_equal "regular:$4.20, large:$8.00, huge:$20.00", @item.price
        end
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

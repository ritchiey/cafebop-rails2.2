require File.dirname(__FILE__) + '/../test_helper'

class MenuItemTest < ActiveSupport::TestCase
  
  context "a given menu_item" do
    
    setup do
      @item = MenuItem.make
    end
    
    should "parse a price correctly" do
      @item.price = "5.12"
      assert_equal 512, @item.price_in_cents
    end

    should "format its price correctly" do
      @item.price_in_cents = 1024
      assert_equal "10.24", @item.price
    end
    
  end
end
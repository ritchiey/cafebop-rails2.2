require File.dirname(__FILE__) + '/../test_helper'

class FlavourTest < ActiveSupport::TestCase

  context "a mock flavour" do
    
    setup do
      @menu_item = MenuItem.new(:id=>1)
      @flavour = Flavour.new(:id=>2)
      @flavour.stubs('menu_item').returns(@menu_item)
      @user = User.new
    end
    
    should "recognise non-manager" do
      @menu_item.expects('managed_by?').returns(false)
      assert !@flavour.managed_by?(@user)
    end

    should "recognise manager" do
      @menu_item.expects('managed_by?').returns(true)
      assert @flavour.managed_by?(@user)
    end

  end



  context "flavour associations" do
    should_have_many :order_items, :dependent=>:nullify
    should_belong_to :menu_item
  end
  
  context "a flavour" do
    should_validate_presence_of :name
    
  end
end

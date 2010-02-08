require File.dirname(__FILE__) + '/../test_helper'

class SizeTest < ActiveSupport::TestCase


  context "a mock size" do
    
    setup do
      @menu_item = MenuItem.new(:id=>1)
      @size = Size.new(:id=>2)
      @size.stubs('menu_item').returns(@menu_item)
      @user = User.new
    end
    
    should "recognise non-manager" do
      @menu_item.expects('managed_by?').returns(false)
      assert !@size.managed_by?(@user)
    end

    should "recognise manager" do
      @menu_item.expects('managed_by?').returns(true)
      assert @size.managed_by?(@user)
    end

  end



  context "size associations" do
    
    # Don't think this is right, see comment in model
    #should_have_many :order_items, :dependent=>:nullify
    should_belong_to :menu_item

  end
  
  context "a size" do
    setup do
      @size = Size.make
    end       
    subject { @size }

    should_validate_presence_of :name
        
    should "be valid" do
      assert_valid @size
    end
    
    context "with invalid data" do
      subject { @size }
      should_not_allow_values_for :price_in_cents, BasicForgery.number(:at_least => -4500, :at_most => 0)
      should_not_allow_values_for :name, nil
    end
  end
end

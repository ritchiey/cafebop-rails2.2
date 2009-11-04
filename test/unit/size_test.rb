require File.dirname(__FILE__) + '/../test_helper'

class SizeTest < ActiveSupport::TestCase

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

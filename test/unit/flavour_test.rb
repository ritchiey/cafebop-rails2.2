require File.dirname(__FILE__) + '/../test_helper'

class FlavourTest < ActiveSupport::TestCase

  context "flavour associations" do
    should_have_many :order_items, :dependent=>:nullify
    should_belong_to :menu_item
  end
  
  context "a flavour" do
    should_validate_presence_of :name
    
    context "with invalid data" do
      
    end
  end
end

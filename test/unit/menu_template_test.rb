require 'test_helper'
require 'yaml'

class MenuTemplateTest < ActiveSupport::TestCase
  should "be valid" do
    assert MenuTemplate.new.valid?
  end
  
  context "a MenuTemplate" do
    setup do
      @menu_name = 'Drinks'
      @menu_template = MenuTemplate.new(:name=>'Cafe Drinks', :yaml_data=>YAML.dump({:name=>@menu_name}))
    end                                 
    
    should "return correct menu_params data" do
      assert_equal @menu_name, @menu_template.menu_params[:name]
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class MenuTest < ActiveSupport::TestCase

  context "a menu not in a shop" do
    setup do
      @menu = Menu.create(:name=>"Drinks",
        :menu_items_attributes=>[{:name=>"Milkshake", :price=>"regular:5.00, large=>8.00", :flavours_attributes=>[{:name=>"vanilla"}]}])
    end

    should "be able to clone itself" do
      cloned = @menu.deep_clone
      json_scope = {:only=>[:name], :include=>{:menu_items=>{:include=>[:sizes, :flavours]}}}
      assert_equal @menu.to_json(json_scope), cloned.to_json(json_scope)
    end

  end
end

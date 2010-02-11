require File.dirname(__FILE__) + '/../test_helper'

class MenuTest < ActiveSupport::TestCase
   
  should "import a menu in CSV format" do
    Menu.expects('create').with(has_entries(
    :name=>"Curry of Thailand",
    :menu_item_attributes=>[{
      :name=>'Green Curry',
      :description=>"choice of chicken, beef or pork",
      :price=>15.9,
      :flavours=>[{:name=>"Chicken"}, {:name=>"Beef"}, {:name=>"Pork"}]
      }])
    )
    data =<<END
Menu,Item Name,Description,Prices,Flavours

Curry of Thailand
,Green Curry,"choice of chicken, beef or pork",15.9,"Chicken, Beef, Pork"
END
    Menu.import_csv(data)
  end


  context "a mock menu" do
    setup do
      @menu = Menu.new(:id=>1)
      @shop = Shop.new(:id=>2)
      @user = User.new(:id=>3)
    end

    should "recognise a non-manager" do
      @user.expects('manages?').returns(false)
      assert !@menu.managed_by?(@user)
    end
    
    should "recognise a manager" do
      @user.expects('manages?').returns(true)
      assert @menu.managed_by?(@user)
    end
  end
  

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

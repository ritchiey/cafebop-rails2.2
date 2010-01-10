require 'test_helper'

class MenuItemsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  
  context "Given a menu" do
    setup do
      @menu = Menu.make
    end

    context "as an authenticated user" do
      setup do
        @user = User.make(:active)
        login_as @user
      end

      should "be able to add a menu item" do
        assert_difference "@menu.menu_items.count", 1 do
          post :create,
              :menu_id=>@menu.id,
              :menu_item=>{"price"=>"0.00",
              :name=>"Pizza",
              :present_flavours=>"true",
              :description=>"Flat, round and delicious"}
            
        end
      end
    end
    

  end
  
  
end

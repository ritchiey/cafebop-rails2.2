require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  
  context "As a new user that's never logged in" do
    setup do
      @user = User.make(:active)
      ApplicationController.stubs(:current_user).returns(@user)
    end
    context "posting to activate_invited with valid parameters" do
      setup do
        @order = Order.make(:user=>@user)
        # Order.expects(:find).at_least_once.returns(@order)
        # Notifications.any_instance.expects(:deliver_welcome).with(@user)
        password = 'wombat'
        post(:activate_invited,
          {:order_id=>@order.id,
          :user=>{
            :password=>password,
            :password_confirmation=>password
          }})
      end

      should_redirect_to("the order") {order_path(@order)}

    end
    
  end
  
  
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase


  context "With an existing order" do
    setup do
      @order = Order.make_unsaved
      @order_id = "13"
      Order.stubs(:find).with(@order_id, any_parameters).returns(@order)
    end

    context "accessing new" do
      setup do
        get :new, :order_id=>@order_id
      end

      should_not_set_the_flash
      should_render_template :new
      should_assign_to(:order) {@order}
      should_assign_to(:shop)
    end
  end
    
  context "with an existing user" do
    setup do
      @user = User.make_unsaved(:active)
      User.stubs('find_by_email').returns(@user)  
      @user_params = {:email=>@user.email,
        :password=>'secret',
        :password_confirmation=>'secret'
        }
    end

    context "that's signed up, post to create" do
      setup do
        @user.stubs('signed_up?').returns(true)
        post :create, :user=>@user_params
      end

      should_set_the_flash_to "You already seem to have an account. Try logging in."
      should_redirect_to("login page") { login_path }
    end
  
    context "that's not signed up, post to create" do
      setup do
        @user.stubs('signed_up?').returns(false)
        post :create, :user=>@user_params
      end

      should_set_the_flash_to "Thanks for signing up! Check your email to permanently activate your account."
      should_redirect_to("the home page") { root_path }
    end
  
    context "that's not signed up but authenticated" do
      setup do
        @user.stubs('signed_up?').returns(false)
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
  
  
end

require 'test_helper'

class WorkContractsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def self.getting_index_for user
    context "getting index" do
      setup do
        user = eval(user, self.send(:binding), __FILE__, __LINE__)
        get :index, :user_id=>user.id
      end
  
      context "" do
        yield
      end
    end
  end

  
  context "With an active_user" do
    setup do
      @user = User.make(:active)
    end

    context "as guest" do
      setup do
        logout
      end

      context "getting index" do
        setup do
          assert !controller.send(:current_user)
          get :index, :user_id=>@user.id
        end

        should_require_login
      end

    end
    
    context "when logged in as that user" do
      setup do
        logout
        login_as @user
        assert_equal @user, controller.send(:current_user)
      end
                                 
      context "getting index" do
        setup do
          get :index, :user_id=>@user.id
        end
        should_render_with_layout
        should_render_template :index
        should_not_set_the_flash
        should_assign_to :work_contracts
      end
    end
    
    
    context "as an active user" do
      setup do
        logout
        @other_user = User.make(:active)
        login_as @other_user
        assert_equal @other_user, controller.current_user
      end
      
      context "getting index of someone else's work_contracts" do
        setup do
          assert controller.current_user.id != @user.id
          get :index, :user_id=>@user.id
        end
        should_not_be_allowed
      end
    end

  end
  
  
end

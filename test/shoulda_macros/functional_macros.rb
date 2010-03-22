module FunctionalMacros

  def logout
    UserSession.find.andand.destroy
  end

  def as user
    context "As #{user}" do
      setup do
        logout
        login_as user
        assert_equal user, controller.current_user
      end
      context "" do
        yield
      end
    end
  end 
  
  def as_guest
    context "As a guest user" do
      setup do
        logout
      end
      context {yield}
    end
  end
  
  def admin
    User.make(:active).tap { |user| user.add_role('cafebop_admin') }   
  end

  def an_active_user
    User.make(:active)
  end
  
  def should_not_let_me
    should_redirect_to("home page") {root_path}
    should_set_the_flash_to "You're not authorized to do that."
  end 
  alias_method :should_not_be_allowed, :should_not_let_me
  
  def should_require_login
    should_redirect_to("the login page") {login_path}
  end

  def should_ask_me_to_signup
    should_redirect_to("the signup page") {signup_path}
  end
end


class ActionController::TestCase
  extend FunctionalMacros
end
module FunctionalMacros

  def as user
    context "As #{user.name}" do
      setup do
        login_as user
      end
      context "" do
        yield
      end
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
  
  def should_require_login
    should_redirect_to("the login page") {login_path}    
  end

end


class ActionController::TestCase
  extend FunctionalMacros
end
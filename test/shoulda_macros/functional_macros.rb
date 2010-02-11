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

end


class ActionController::TestCase
  extend FunctionalMacros
end
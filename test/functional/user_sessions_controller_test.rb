require 'test_helper'

class UserSessionsControllerTest < ActionController::TestCase

  setup :activate_authlogic
  
  context "A valid user session" do
    setup do
      @password = "Shnicket"
      @user = User.make(:active=>true, :email=>'hagrid@cafebop.com', :password=>@password, :password_confirmation=>@password)
      assert @user_session = UserSession.create(:email=>@user.email, :password=>@password)
    end

  end
  
  
end

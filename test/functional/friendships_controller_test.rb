require File.dirname(__FILE__) + '/../test_helper'

class FriendshipsControllerTest < ActionController::TestCase     

  setup :activate_authlogic
   
  context "an authenticated user" do
    setup do
      @user = User.make(:active)
      login_as @user
    end

    should "be able to add a friend with a valid email" do     
      assert_difference "@user.friendships.count", 1 do
        post :create, :friendship=>{:friend_email=>'bob@cafebop.com'}
      end
    end
    
    
  end

end
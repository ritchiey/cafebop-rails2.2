require File.dirname(__FILE__) + '/../test_helper'

class FriendshipTest < ActiveSupport::TestCase
  
  context "A user" do
    setup do
      @user = User.make
    end

    should "be able to create a friendship with a non-existing user" do
      assert_difference "Friendship.count", 1 do
        @user.friendships.create(:friend_email=>"bob@cafebop.com")
      end
      assert @user.friends
    end          

    should "be able to create a friendship with an existing user" do
      @bob = User.make(:email=>"bob@cafebop.com")        
      assert_difference "Friendship.count", 1 do
        @user.friendships.create(:friend_email=>"bob@cafebop.com")
      end
      assert_same_elements([@bob], @user.friends.all)
    end          

    context "with a friend with email '#{"bob@cafebop.com"}'" do
      setup do 
        @bob = User.make(:email=>"bob@cafebop.com")        
        @user.friendships.create(:friend_email=>"bob@cafebop.com")
      end

      should "be able to add a second friend" do    
        assert_does_not_contain(@user.friends.*.email, 'mary@cafebop.com', "extra_msg")
        assert_difference "Friendship.count", 1 do
          @user.friendships.create(:friend_email=>"mary@cafebop.com")
        end
      end
      
      should "be not be able to create another friendship with the same user" do
        assert_no_difference "Friendship.count" do
          @user.friendships.create(:friend_email=>"bob@cafebop.com")
        end
        assert_same_elements([@bob], @user.friends.all)
      end
      
    end
    
  end
  
  
end

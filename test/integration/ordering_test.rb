require 'test_helper'

class OrderingTest < ActionController::IntegrationTest
  
  context "A signed in user" do
    
    setup do                       
      @user = login
    end
    
    context "with friends" do
      setup do
        add_friends
      end

      context "who places an order" do
        setup do
          @order = place_order
        end

        should "be the user for that order" do
          @order.reload
          assert_equal @user, @order.user
        end
      
        should "be able to invite others" do
          click_link "Offer Friends"
          @user.friends.each {|friend| check(friend.to_s)}
          uncheck @user.friends.last.to_s
          click_button 'Send Invites'
        end
        
        
      end
      
    end
    
  end
end
    
  
  


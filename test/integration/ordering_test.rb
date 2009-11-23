require 'test_helper'

class OrderingTest < ActionController::IntegrationTest
  
  context "A signed in user" do
    
    setup do                       
      @user = login
    end
    
    context "with friends" do
      setup do
        assert_no_difference "ActionMailer::Base.deliveries.count" do
          add_friend 'bobo@cafebop.com'
          add_friend 'mary@cafebop.com'
        end
      end

      context "who places an order" do
        setup do
          @order = place_order
        end

        should "be the user for that order" do
          @order.reload
          assert_equal @user, @order.user
        end
      
        should "be able to invite others and have them accept" do
          click_link "Offer Friends"
          @user.friends.each {|friend| uncheck("invite_user_#{friend.id}")}
          check "invite_user_#{@user.friends.last.id}"
          click_button 'Send Invites'
          invite_email = ActionMailer::Base.deliveries.last
          assert_match /#{@user} is going to #{@order.shop} and can bring you something back/, invite_email.body
          invite_email.body =~ /(http:.*) - Show me the menu/
          accept_url = $1
          logout
          visit accept_url
          assert_logged_in_as @user.friends.last
          assert_contain 'Your Order'
          
          #http://cafebop.com/orders/decline - Not this time thanks
          
        end

        
        
      end
      
    end
    
  end
end

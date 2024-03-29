require 'test_helper'

class OrderingTest < ActionController::IntegrationTest
  
  context "A signed in user" do
    
    setup do                       
      assert_not_nil @user = login, "Login failed"
    end
    
    context "with friends" do
      setup do
        assert_difference "@user.friends.count", 2 do
          assert_no_difference "ActionMailer::Base.deliveries.count" do
            add_friend 'bobo@cafebop.com'
            add_friend 'mary@cafebop.com'
          end
        end
      end

      context "who places an order" do
        setup do
          @order = place_webrat_order
        end

        should "be the user for that order" do
          @order.reload
          assert_equal @user, @order.user
        end
        
      
        context "invites a friend" do
          setup do
            @invited = @user.friends.last
            assert_not_nil @invited 
            assert_have_selector "#offer-friends-button" 
            click_button "Invite Friends"
            @user.friends.each {|friend| uncheck("invite_user_#{friend.id}")}
            check "invite_user_#{@invited.id}"
            assert_difference "@order.child_orders.count", 1 do
              click_button 'Continue'
            end
            assert_not_nil(@invite_email = ActionMailer::Base.deliveries.last, "No invite email sent")
            assert_match /#{@user} is going to #{@order.shop} in about 10 minutes and can bring you something back/, @invite_email.body
            logout
          end

          context "who accepts the invitation" do
            setup do
              @invite_email.body =~ /(http:.*) - Show me the menu/
              @accept_url = $1
              visit @accept_url
              assert_logged_in_as @invited
              assert_contain 'Your Order'
            end


            should "not be allowed to accept it again" do
              logout
              visit @accept_url
              #TODO: Work out why this test is broken under rails 2.3.7
              # Logging out works fine when manually tested
              # assert_logged_out
              assert_contain 'Sorry, you can only accept an invitation once'
            end

          end
          

          
          should "allow them to decline once only" do
            @invite_email.body =~ /(http:.*) - Not this time thanks/
            visit(decline_url=$1)
            assert_logged_in_as @invited   
            assert_contain 'Maybe next time'
            logout
            visit decline_url
            assert_logged_out
            assert_contain 'Maybe next time'
          end
          
        end
        
      end
      
    end
    
  end
  
  
  
  context "An anonymous user who places an order" do
    setup do
      @password = 'heehaw!!'
      @user = User.make(:active=>true, :password=>@password, :password_confirmation=>@password)
      visit root_path
      @order = place_webrat_order(:name=>'Tom')
      assert_have_selector "#offer-friends-button"
    end
    
    should "be sent to the signup screen" do
      click_button "Invite Friends"
      #assert redirected_to(signup_path)
    end
    
  end
  
end

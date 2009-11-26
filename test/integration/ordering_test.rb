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
        
      
        context "invites a friend" do
          setup do
            @invited = @user.friends.last
            assert_not_nil @invited
            click_button "Offer Friends"
            @user.friends.each {|friend| uncheck("invite_user_#{friend.id}")}
            check "invite_user_#{@invited.id}"
            click_button 'Send Invites'
            @invite_email = ActionMailer::Base.deliveries.last
            assert_match /#{@user} is going to #{@order.shop} and can bring you something back/, @invite_email.body
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
              assert_logged_out
              assert_contain 'Sorry, you can only accept an invitation once'
            end

            should_eventually "be able to edit and confirm their order" do
              add_to_last_order
              click_link "Confirm Order"
              assert_contain "Your order will be collected from #{@order.shop} by #{@order.user}."
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
      @user = User.make(:password=>@password, :password_confirmation=>@password)
      visit root_path
      @order = place_order
      assert_contain "Offer Friends"
#      save_and_open_page
    end

    should_eventually "be able to enter login as an existing user on the invite others screen" do
      click_button "Offer Friends"
      fill_in "user_session_email", :with=>@user.email
      fill_in "user_session_password", :with=>@password
      click_button "Send Invites"
    end
    
  end
  
end

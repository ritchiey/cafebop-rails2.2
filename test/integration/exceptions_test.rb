require 'test_helper'

class ExceptionsTest < ActionController::IntegrationTest

  setup :activate_authlogic
  
  context "An authenticated user with no friends" do
    setup do
      get root_url
      @user = login
    end
  
    context "and a pending order" do
      setup do
        @order = @user.orders.make
      end

      should "be able to add a friend" do 
        friend_email = "snape@cafebop.com"
        assert_difference "@user.friends.count", 1 do
          put send_invitations_order_url(@order), {"commit"=>"Add",
           "order"=>{"minutes_til_close"=>"5"},
           "friendship"=>{"friend_email"=>friend_email}
          }
        end
        assert_redirected_to invite_order_url(@order)
      end

    end

  end
  
end

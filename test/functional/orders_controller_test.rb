require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  context "With an order" do
    setup do
      @order = Order.make
    end
    
    context "when logged in" do
      setup do
        login_as User.make(:active)
      end
    
      context "show action" do
        should "render show template" do
          get :show, :id =>@order
          assert_template 'show'
        end
      end
      
    end
  end
end

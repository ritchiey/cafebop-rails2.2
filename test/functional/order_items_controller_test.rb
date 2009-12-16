require 'test_helper'

class OrderItemsControllerTest < ActionController::TestCase
  setup :activate_authlogic                                  

  context "With an existing order_item" do
    setup do
      assert_difference "OrderItem.state_eq('queued').count", 1 do
        @order_item = OrderItem.make(:state=>'queued')
        assert_not_nil @order_item.order
      end
    end

    context "an anonymous user" do
      setup do
        logout
      end

      should "not be able to make it" do
        assert_no_difference "OrderItem.state_eq('made').count" do
          assert_not_nil @order_item.order
          put :make, :id=>@order_item.id
        end
      end
    end

    context "an active user " do
      setup do 
        @user = User.make(:active)
        login_as @user
      end

      should "not be able to make it" do
        assert_no_difference "OrderItem.state_eq('made').count" do
          put :make, :id=>@order_item.id
        end
      end
    
      context "who is a staff member of the store from which the item has been ordered" do
        setup do
          shop = @order_item.order.shop
          shop.work_contracts.make(:user=>@user, :role=>'staff')
        end

        should "be able to make it" do
          assert_difference "OrderItem.state_eq('made').count", 1 do
            put :make, :id=>@order_item.id
          end
        end
      end
    
    end

  end
end

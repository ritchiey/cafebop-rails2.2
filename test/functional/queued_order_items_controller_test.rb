require 'test_helper'

class QueuedOrderItemsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  
  context "Given an existing order_item" do
    setup do
      @order_item = OrderItem.make
    end

    context "as an anonymous user" do
      setup do
        controller.stubs(:current_user).returns(nil)
      end
      
      context "showing the order_item" do
        setup {get :show, :id=>@order_item.id, :format=>'json'}
        should_require_login
      end
      
      context "trying to make the order item" do
        setup do
          assert_no_difference "OrderItem.state_eq('made').count" do
            put :make, :id=>@order_item.id, :format=>'json'
          end
        end
          
        should_require_login
      end
      
    end
    
    context "as someone who can't access the order_item's shop's queues" do
      setup do
        @user = User.make(:active)
        @user.expects('can_access_queues_of?').with(@order_item.shop).returns(false)
        controller.stubs(:current_user).returns(@user)
        assert_equal @user, controller.current_user
      end

      context "showing the order_item" do
        setup {get :show, :id=>@order_item.id, :format=>'json'}
        should_not_be_allowed
      end
      
      context "trying to make the order item" do
        setup do
          assert_no_difference "OrderItem.state_eq('made').count" do
            put :make, :id=>@order_item.id, :format=>'json'
          end
        end
          
        should_not_be_allowed
      end
      
    end
    
    
    context "as someone who can access the order_item's shop's queues" do
      setup do
        @user = User.make(:active)
        @user.expects('can_access_queues_of?').with(@order_item.shop).returns(true)
        controller.stubs(:current_user).returns(@user)
        assert_equal @user, controller.current_user
      end
      
      context "showing the order_item" do
        setup {get :show, :id=>@order_item.id, :format=>'json'}
        should_respond_with :success
        should_assign_to :order_item
        should_not_set_the_flash
      end
      
      context "trying to make the order item" do
        setup do
          put :make, :id=>@order_item.id, :format=>'json'
        end
          
        should_respond_with :success
        should_assign_to :order_item
        should_not_set_the_flash
      end
      
    end

  end
  




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
          Shop.any_instance.stubs(:"can_have_queues?").returns(true)
          shop.work_contracts.make(:user=>@user, :role=>'staff')
          assert @user.works_at?(shop)
          assert shop.can_have_queues?
          assert @user.can_access_queues_of?(shop)
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

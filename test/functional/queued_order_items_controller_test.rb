require 'test_helper'

class QueuedOrderItemsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  
  context "Given an existing order_item or two" do
    setup do
      @order = Order.make
      @order_item = @order.order_items.make
      @order_item2 = @order.order_items.make
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
      
      context "trying to make_all the order_items" do
        setup do
          put :make_all, :order_item_ids=>[@order_item.id, @order_item2.id], :format=>'json'
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

      context "trying to make_all the order_items" do
        setup do
          put :make_all, :order_item_ids=>[@order_item.id, @order_item2.id], :format=>'json'
        end
        should_not_be_allowed
      end
      
    end
    
    
    context "as someone who can access the order_item's shop's queues" do
      setup do
        @user = User.make(:active)
        assert_not_nil @order_item
        @user.expects('can_access_queues_of?').with(@order_item.shop).at_least_once.returns(true)
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

      context "trying to make_all the order_items" do
        setup do
          ids = [@order_item.id, @order_item2.id]
          assert_equal @order_item.shop, @order_item2.shop
          OrderItem.any_instance.stubs('make!').returns(true)
          put :make_all, :order_item_ids=>ids, :format=>'json'
        end
        should_assign_to(:order) {@order}
        should_respond_with :success
        should_not_set_the_flash
      end
      
    end

  end
  
end

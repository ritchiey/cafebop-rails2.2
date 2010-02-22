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
    end

  end
  
  
end

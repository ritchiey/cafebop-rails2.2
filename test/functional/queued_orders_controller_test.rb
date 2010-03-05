require 'test_helper'

class QueuedOrdersControllerTest < ActionController::TestCase
  
  setup :activate_authlogic

  
  context "Given an existing order" do
    setup do
      @order = Order.make
    end


    context "as an anonymous user" do
      setup do
        controller.stubs(:current_user).returns(nil)
      end
      
      context "showing the order" do
        setup {get :show, :id=>@order.id, :format=>'json'}
        should_require_login
      end
      
      context "cancelling the order" do
        setup {put :cancel, :id=>@order.id, :format=>'json'}
        should_require_login
      end
      
      context "reporting a no_show for the order" do
        setup {put :no_show, :id=>@order.id, :format=>'json'}
        should_require_login
      end
      
    end
    
    context "as someone who can't access the order's shop's queues" do
      setup do
        @user = User.make(:active)
        @user.expects('can_access_queues_of?').with(@order.shop).returns(false)
        controller.stubs(:current_user).returns(@user)
        assert_equal @user, controller.current_user
      end

      context "showing the order" do
        setup {get :show, :id=>@order.id, :format=>'json'}
        should_not_be_allowed
      end


      context "cancelling the order" do
        setup {put :cancel, :id=>@order.id, :format=>'json'}
        should_not_be_allowed
      end
      
      context "reporting a no_show for the order" do
        setup {put :no_show, :id=>@order.id, :format=>'json'}
        should_not_be_allowed
      end
      

    end
    
    context "as someone who can access the order's shop's queues" do
      setup do
        @user = User.make(:active)
        @user.expects('can_access_queues_of?').with(@order.shop).returns(true)
        controller.stubs(:current_user).returns(@user)
        assert_equal @user, controller.current_user
      end
      
      context "showing the order" do
        setup {get :show, :id=>@order.id, :format=>'json'}
        should_respond_with :success
        should_assign_to :order
        should_not_set_the_flash
      end

      context "cancelling the order" do
        setup do
          Order.expects(:find).returns(@order)
          @order.expects(:cancel!).once
          put :cancel, :id=>@order.id, :format=>'json'
        end
        should_respond_with :success
        should_assign_to :order
        should_not_set_the_flash
      end
      
      context "reporting a no_show for the order" do
        setup do
          Order.expects(:find).returns(@order)
          @order.expects(:no_show!).once
          put :no_show, :id=>@order.id, :format=>'json'
        end
        should_respond_with :success
        should_assign_to :order
        should_not_set_the_flash
      end

      context "calling make_all for the order" do
        setup do
          put :make_all_items, :id=>@order.id, :format=>'json'
        end

        before_should "invoke make_all_items!" do
          Order.expects(:find).returns(@order)
          @order.expects(:make_all_items!).once
        end
        
      end
      

    end

  end
  
  
end

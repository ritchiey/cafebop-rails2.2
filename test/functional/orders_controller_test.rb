require 'test_helper'

# Don't know how to write this. Orders are dependent on shops and you
# can only manipulate your own order. So I don't know how to write effective
# functional tests for this. See order_ownership_test.rb

class OrdersControllerTest < ActionController::TestCase
  setup :activate_authlogic                                  
  
  def self.should_be_denied
    should_redirect_to("the new order page") {new_shop_order_path(@order.shop)}
    should_set_the_flash_to "Whoa! That's not yours."
  end
  
  context "Given an order created anonymously" do
    setup do
      @shop = Shop.make_unsaved
      @shop.stubs(:id).returns(12)
      @order = Order.make_unsaved
      @order.stubs(:id).returns(14)
      @order.stubs(:shop).returns(@shop)
      Order.stubs(:find).returns(@order)
    end
  
    context "by me" do
      setup do
        @order.stubs(:mine?).returns(true)
      end

      should "be able to be shown" do
        get :show, :id=>@order.id
        assert_template :show
      end                        

      context "when edited" do
        setup do
          get :edit, :id=>@order.id
        end
        should_respond_with :success
        should_not_set_the_flash
      end

      context("given order is valid") do
        setup do
          @order.expects(:valid?).returns(true)
        end          
        context "when updated" do
          setup do
            @order.expects(:update_attributes).returns(true)
            put :update, :id=>@order.id
          end
          should_redirect_to("show order") {order_path(@order)}
          should_not_set_the_flash
        end
      end

      context("given order is invalid") do
        setup do
          @order.expects(:valid?).returns(false)
        end          
        context "when updated" do
          setup do
            @order.expects(:update_attributes).returns(true)
            put :update, :id=>@order.id
          end
          should_redirect_to("edit order") {edit_order_path(@order)}
        end
      end

      context "inviting a user" do 
        setup do
          get :invite, :id=>@order.id
        end
        should_redirect_to("signup page") {signup_path(:order_id=>@order.id)}
      end
      
      context "which can be queued" do
        setup do
          @order.stubs(:can_be_queued?).returns(true)
        end

        context "paying in shop" do
          setup do
            post :place, :commit=>'Pay In Shop', :id=>@order.id
          end

          should_redirect_to("signup page") {signup_path(:order_id=>@order.id)}
          # before_should "call pay_in_shop!" do
          #   @order.expects(:pay_in_shop).once
          # end
        end
      end
      
    end

    context "by someone else" do
      setup do
        @order.stubs(:mine?).returns(false)
      end
      
      context "when shown" do
        setup do
          get :show, :id=>@order.id
        end
        should_be_denied
      end
      
      context "when edited" do
        setup do
          get :edit, :id=>@order.id
        end
        should_be_denied
      end

      context "when updated" do
        setup do
          put :update, :id=>@order.id
        end
        should_be_denied
      end
      
    end
    
  # 
  #   should "be able to be updated" do
  #   
  #   end                        
  # 
  #   should "be able to confirmed" do
  #   
  #   end
  # 
  #   should "be able to be summarised" do
  #   
  #   end
  # 
  #   should "not be able to be accepted" do
  #   
  #   end
  # 
  #   should "not be able to be declined" do
  #   
  #   end
  # 
  #   should "not be able to be closed when not invited" do
  #   
  #   end
  # 
  end  
end

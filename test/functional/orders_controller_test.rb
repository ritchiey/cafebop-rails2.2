require 'test_helper'

# Don't know how to write this. Orders are dependent on shops and you
# can only manipulate your own order. So I don't know how to write effective
# functional tests for this. See order_ownership_test.rb

class OrdersControllerTest < ActionController::TestCase
  setup :activate_authlogic                                  
  
  # context "Given an order created anonymously" do
  #   setup do
  #     @order = place_order
  #   end
  # 
  #   should "be able to be shown" do
  #     get :show, :id=>@order.id
  #     assert_template :show
  #   end                        
  # 
  #   should "be able to be edited" do
  #     get :edit, :id=>@order.id
  #     assert_template :edit
  #   end
  # 
  #   should "be able to be updated" do
  #   
  #   end                        
  # 
  #   should "be able to invite" do
  #     get :invite, :id=>@order.id
  #     assert_template :invite
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
  # end  
end

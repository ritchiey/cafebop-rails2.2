require 'test_helper' 


class PaypalEnabledTest < ActiveSupport::TestCase

  context "A pending order from a paypal enabled shop" do
    setup do
      @shop = Shop.make
      @shop.go_express!
      @shop.start_accepting_queued_orders!
      @shop.enable_paypal_payments!
      @order = Order.make(:shop=>@shop)
    end

    should_eventually "return appropriate paypal_json" do
      json = ActiveSupport::JSON
      payment = json.decode(@order.send :payment_json)
      assert_equal 'PAY', payment['actionType']
    end
    
    should_eventually "be able to get the payment token from PayPal" do
      response = @order.request_paypal_authorization!
      assert response.succeeded?
      assert_not_nil response.pay_key
    end
  end
  
end
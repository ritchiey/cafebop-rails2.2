require 'test_helper' 


class BrowserSessionTest < ActiveSupport::TestCase
  
  context "A BrowserSession" do
    setup do
      @session = {}
      @bs = BrowserSession.new(@session)
    end

    should "be able to persist and restore an order" do
      emails = ["hagrid@cafebop.com", "malfoy@cafebop.com"]
      order = Order.make(:minutes_til_close=>7,
        :invited_user_attributes=>emails)
      @bs.persist_order(order)
      assert_equal 7, @session[:order][:minutes_til_close]
      newOrder = Order.make
      @bs.restore_order(newOrder)
      assert_equal 7, newOrder.minutes_til_close
      assert_same_elements emails, newOrder.invited_user_attributes
    end
  end
  
end

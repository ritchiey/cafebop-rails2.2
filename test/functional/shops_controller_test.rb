require 'test_helper'

class ShopsControllerTest < ActionController::TestCase
  context "existing functional tests" do
    setup do
      @request.cookies[SESSION_KEY] = "faux session"
    end

    should "continue to work" do
      get :index
      assert_response :success
    end
  end
  
  context "cookies are disabled " do
    setup do
       @request.cookies.delete SESSION_KEY
    end
    
    should "redirect results" do     
      get :index
      assert_redirected_to :controller => :shops, :action => :cookies_test
    end
  end
end

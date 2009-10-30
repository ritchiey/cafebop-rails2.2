require 'test_helper'

class FrontControllerTest < ActionController::TestCase
  context "existing functional tests" do
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
      assert_redirected_to :controller => :front, :action => :cookies_test
    end
  end
end

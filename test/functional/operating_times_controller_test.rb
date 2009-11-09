require 'test_helper'

class OperatingTimesControllerTest < ActionController::TestCase
  context "new action" do
    should "render new template" do
      get :new
      assert_template 'new'
    end
  end
  
  context "create action" do
    should "render new template when model is invalid" do
      OperatingTimes.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      OperatingTimes.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to root_url
    end
  end
  
  context "edit action" do
    should "render edit template" do
      get :edit, :id => OperatingTimes.first
      assert_template 'edit'
    end
  end
  
  context "update action" do
    should "render edit template when model is invalid" do
      OperatingTimes.any_instance.stubs(:valid?).returns(false)
      put :update, :id => OperatingTimes.first
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      OperatingTimes.any_instance.stubs(:valid?).returns(true)
      put :update, :id => OperatingTimes.first
      assert_redirected_to root_url
    end
  end
  
  context "destroy action" do
    should "destroy model and redirect to index action" do
      operating_times = OperatingTimes.first
      delete :destroy, :id => operating_times
      assert_redirected_to root_url
      assert !OperatingTimes.exists?(operating_times.id)
    end
  end
end

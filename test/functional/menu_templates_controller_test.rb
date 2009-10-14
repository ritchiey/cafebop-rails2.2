require 'test_helper'

class MenuTemplatesControllerTest < ActionController::TestCase
  context "index action" do
    should "render index template" do
      get :index
      assert_template 'index'
    end
  end
  
  context "show action" do
    should "render show template" do
      get :show, :id => MenuTemplate.first
      assert_template 'show'
    end
  end
  
  context "new action" do
    should "render new template" do
      get :new
      assert_template 'new'
    end
  end
  
  context "create action" do
    should "render new template when model is invalid" do
      MenuTemplate.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      MenuTemplate.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to menu_template_url(assigns(:menu_template))
    end
  end
  
  context "edit action" do
    should "render edit template" do
      get :edit, :id => MenuTemplate.first
      assert_template 'edit'
    end
  end
  
  context "update action" do
    should "render edit template when model is invalid" do
      MenuTemplate.any_instance.stubs(:valid?).returns(false)
      put :update, :id => MenuTemplate.first
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      MenuTemplate.any_instance.stubs(:valid?).returns(true)
      put :update, :id => MenuTemplate.first
      assert_redirected_to menu_template_url(assigns(:menu_template))
    end
  end
  
  context "destroy action" do
    should "destroy model and redirect to index action" do
      menu_template = MenuTemplate.first
      delete :destroy, :id => menu_template
      assert_redirected_to menu_templates_url
      assert !MenuTemplate.exists?(menu_template.id)
    end
  end
end

require 'test_helper'

class CuisinesControllerTest < ActionController::TestCase    
  
  def login_as_admin
    user = User.make
    user.add_role('cafebop_admin')
    UserSession.create(user)
  end               
  
  context "With a cuisine" do
    setup do
      @cuisine = Cuisine.make
    end
    
    context "when logged in as an administrator" do
      setup do
        login_as_admin
      end
      
    
      context "index action" do
        should "render index template" do
          get :index
          assert_template 'index'
        end
      end
  
      context "show action" do
        should "render show template" do
          get :show, :id => Cuisine.first
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
          Cuisine.any_instance.stubs(:valid?).returns(false)
          post :create
          assert_template 'new'
        end
    
        should "redirect when model is valid" do
          Cuisine.any_instance.stubs(:valid?).returns(true)
          post :create
          assert_redirected_to cuisine_url(assigns(:cuisine))
        end
      end
  
      context "edit action" do
        should "render edit template" do
          get :edit, :id => Cuisine.first
          assert_template 'edit'
        end
      end
  
      context "update action" do
        should "render edit template when model is invalid" do
          Cuisine.any_instance.stubs(:valid?).returns(false)
          put :update, :id => Cuisine.first
          assert_template 'edit'
        end
  
        should "redirect when model is valid" do
          Cuisine.any_instance.stubs(:valid?).returns(true)
          put :update, :id => Cuisine.first
          assert_redirected_to cuisine_url(assigns(:cuisine))
        end
      end
  
      context "destroy action" do
        should "destroy model and redirect to index action" do
          cuisine = Cuisine.first
          delete :destroy, :id => cuisine
          assert_redirected_to cuisines_url
          assert !Cuisine.exists?(cuisine.id)
        end
      end

    end

  end

end

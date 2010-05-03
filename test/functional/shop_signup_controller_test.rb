require 'test_helper'

class ShopSignupControllerTest < ActionController::TestCase
  
  context "calling new" do
    setup do
      get :new
    end

    should_assign_to :new_shop, :class=>Shop
    should_render_template :new
  end                 
  
  context "with a new shop" do
    setup do
      @shop = Shop.make_unsaved
      Shop.expects(:new).returns(@shop)
      @shop.expects(:save).returns(true)  
      @shop.expects(:id).at_least_once.returns(37)
    end

    context "calling update" do
      setup do
        post :create, @shop_parameters
      end

      before_should "attempt to create the shop" do
        @shop_parameters =  {:shop=>{
          :owner_email=>'bob@cafebop.com',
          :name=>"Happy's Takeaway",
          :steet_address=>"1 Happy Place, Happytown",
          :phone=>'2222222',
          :permalink=>'happys'
          }
        }
      end
      should_redirect_to('activation form') {activation_form_shop_signup_path(@shop)}
    end
  end

  context "With an existing inactive shop" do
    setup do
      @shop = Shop.make_unsaved
      Shop.expects(:find).returns(@shop)
      @shop.expects(:id).at_least_once.returns(37)
    end

    context "Displaying the activation form" do
      setup do
        get :activation_form, :id=>@shop.id
      end
      should_assign_to :new_shop
      should_render_template :activation_form
    end
  end
  
  
  
  
end

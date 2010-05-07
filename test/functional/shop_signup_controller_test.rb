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

    context "calling create" do
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
      @shop = Shop.make_unsaved(:owner) 
      @owner = User.make_unsaved
      Shop.expects(:find_by_id_or_permalink).returns(@shop)
      @shop.expects(:id).at_least_once.returns(37)
      @shop.stubs(:active?).returns(false)  
      @shop.stubs(:owner).returns(@owner)
    end

    context "displaying the activation form" do
      setup do
        get :activation_form, :id=>@shop.id
      end
      should_assign_to :new_shop
      should_render_template :activation_form
    end
    
    context "if the owner of the shop isn't already signed up" do
      setup do
        @owner.expects(:signed_up?).returns(false)
      end

      context "calling update" do
        setup do
          put :update, :id=>@shop.id, :shop=>{'activation_confirmation'=>'12345', 'name'=>'Ignore this'}
        end

        before_should "only update the activation code and login as the owner" do
          @shop.expects(:update_attributes).with('activation_confirmation'=>'12345').returns(true)
          controller.expects(:login_as).with(@owner)
        end
        should_redirect_to('choose password form') {choose_password_for_shop_signup_path(@shop)}
      end

    end

    context "if the owner of the shop is already signed up" do
      setup do
        @owner.expects(:signed_up?).returns(true)
      end

      context "calling update" do
        setup do
          put :update, :id=>@shop.id, :shop=>{'activation_confirmation'=>'12345', 'name'=>'Ignore this'}
        end

        before_should "only update the activation code and login as the owner" do
          @shop.expects(:update_attributes).with('activation_confirmation'=>'12345').returns(true)
          controller.expects(:login_as).with(@owner)
        end
        should_redirect_to('shop created screen') {active_shop_signup_path(@shop)}
      end

    end


  end
  
  
  
  
end

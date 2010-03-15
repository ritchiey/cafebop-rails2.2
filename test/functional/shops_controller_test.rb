require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  test "uploading a background image" do  
    image_upload = fixture_file_upload('files/logo.png', 'image/png')
    post :create, :name=>"Test Shop", :header_background=>image_upload
  end
  
  setup :activate_authlogic

  context "With an express shop" do
    setup do
      @shop = Shop.make
      @shop.transition_to('express')
    end
    
    should "redirect to list of shops on search with no parameters" do
      get :search
      assert_redirected_to shops_path
    end
    
    context "when unauthenticated" do

      should "not be able to edit shop" do
        get :edit, :id => @shop.to_param    
        assert_redirected_to login_url
      end

      should "not be able to update a shop" do
        put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
        assert_redirected_to login_url
      end
      
      should "be able to create a shop" do
        assert_difference "Shop.count", 1 do
          post :create, :shop=>{:name=>"Sniggles", :phone=>"22222", :street_address=>"987 slkdjlksdjdakl", :lat=>-31.9678531, :lng=>115.8909351}
        end
      end     
      
      should "not be able to delete a shop" do
        delete :destroy, :id => @shop.to_param
        assert_redirected_to login_url
      end
      
    end
    
    context "when logged in as an active user" do
      setup do
        @user = User.make(:active)
        login_as @user
      end

      should "not be able to edit shop" do
        get :edit, :id => @shop.to_param    
        assert_redirected_to new_shop_order_url(@shop)
      end

      should "not be able to update a shop" do
        assert_no_difference "Shop.name_eq('Sniggles').count" do
          put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
          assert_redirected_to new_shop_order_url(@shop)
        end
      end
      
      should "be able to update the franchise and cuisine on a community shop" do
        @shop.state = 'community'
        @shop.save!
        assert @shop.community?
        Cuisine.create!(:name=>'strawberries')
        # Cuisine.make
        assert_difference "@shop.cuisines.count", 1 do
          put :update, :id=>@shop.to_param, :shop=>{:cuisine_ids=>[Cuisine.first.id]}
          assert_redirected_to new_shop_order_url(@shop)
          @shop.reload
        end
      end
      
      should "be able to create a shop" do
        assert_difference "Shop.count", 1 do
          post :create, :shop=>{:name=>"Sniggles", :phone=>"22222", :street_address=>"987 slkdjlksdjdakl", :lat=>-31.9678531, :lng=>115.8909351}
        end
      end     
      
      should "not be able to delete a shop" do
        assert_no_difference "Shop.count" do
          delete :destroy, :id => @shop.to_param
          assert_redirected_to new_shop_order_url(@shop)
        end
      end
    end
    
    context "when logged in as a manager of the shop" do
      setup do
        @manager = User.make(:active)
        @shop.work_contracts.make(:user=>@manager, :role=>'manager')
        assert @shop.save
        login_as @manager   
      end

      should "be able to edit shop" do
        get :edit, :id => @shop.to_param
        assert_template 'edit'
      end     
              
      should "be able to update a shop" do
        put :update, :id=>@shop.to_param, :shop=>{:name=>"Gumbys"}
        @shop.reload
        assert_redirected_to new_shop_order_url(@shop)
        assert_equal "Gumbys", @shop.name
      end     
            
    end
    
    
    context "when logged in as an administrator" do
      setup do
        login_as_admin
      end
      
      should "be able to edit shop" do
        get :edit, :id => @shop.to_param
        assert_template 'edit'
      end     
              
      should "be able to update a shop" do
        put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
        @shop.reload
        assert_redirected_to new_shop_order_url(@shop)
        assert_equal "Sniggles", @shop.name
      end     
              
      should "be able to create a shop" do
        assert_difference "Shop.count", 1 do
          post :create, :shop=>{:name=>"Sniggles", :phone=>"22222", :street_address=>"987 slkdjlksdjdakl", :lat=>-31.9678531, :lng=>115.8909351}
          assert_redirected_to new_shop_order_path(Shop.last)
        end
      end     
              
      should "be able to delete a shop" do
        assert_difference "Shop.count", -1 do
          delete :destroy, :id => @shop.to_param
          assert_redirected_to root_url
        end
      end
      
    end

  end

end

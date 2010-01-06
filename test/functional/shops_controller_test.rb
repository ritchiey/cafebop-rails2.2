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
    
    context "when unauthenticated" do

      should "not be able to edit shop" do
        get :edit, :id => @shop.permalink    
        assert_redirected_to login_url
      end

      should "not be able to update a shop" do
        put :update, :id=>@shop.permalink, :shop=>{:name=>"Sniggles"}
        assert_redirected_to login_url
      end
      
      should "not be able to create a shop" do
        assert_no_difference "Shop.count" do
          post :create, :shop=>{:name=>"Sniggles", :phone=>"22222", :street_address=>"987 slkdjlksdjdakl"}
          assert_redirected_to login_url
        end
      end     
      
      should "not be able to delete a shop" do
        delete :destroy, :id => @shop.permalink
        assert_redirected_to login_url
      end
      
    end
    
    context "when logged in as an active user" do
      setup do
        @user = User.make(:active)
        login_as @user
      end

      should "not be able to edit shop" do
        get :edit, :id => @shop.permalink    
        assert_redirected_to new_shop_order_url(@shop)
      end

      should "not be able to update a shop" do
        assert_no_difference "Shop.name_eq('Sniggles').count" do
          put :update, :id=>@shop.permalink, :shop=>{:name=>"Sniggles"}
          assert_redirected_to new_shop_order_url(@shop)
        end
      end
      
      should "be able to update the franchise and cuisine on a community shop" do
        @shop.state = 'community'
        @shop.save!
        assert @shop.community?
        Cuisine.make
        assert_difference "@shop.cuisines.count", 1 do
          put :update, :id=>@shop.permalink, :shop=>{:cuisine_ids=>[Cuisine.first.id]}
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
          delete :destroy, :id => @shop.permalink
          assert_redirected_to new_shop_order_url(@shop)
        end
      end
    end
    
    
    context "when logged in as an administrator" do
      setup do
        login_as_admin
      end
      
      should "be able to edit shop" do
        get :edit, :id => @shop.permalink    
        assert_template 'edit'
      end     
              
      should "be able to update a shop" do
        put :update, :id=>@shop.permalink, :shop=>{:name=>"Sniggles"}
        assert_redirected_to new_shop_order_url(@shop)
        @shop.reload
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
          delete :destroy, :id => @shop.permalink
          assert_redirected_to root_url
        end
      end
      
    end

  end

end

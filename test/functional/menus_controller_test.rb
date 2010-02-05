require 'test_helper'

class MenusControllerTest < ActionController::TestCase

  setup :activate_authlogic

  context "With an express shop with a menu" do
    setup do
      @shop = Shop.make
      @shop.transition_to('express')
      @menu = @shop.menus.make
    end

    context "when unauthenticated" do

      should "not be able to edit the menu" do
        get :edit, :id => @menu.to_param
        assert_redirected_to login_url
      end

      should "not be able to update a menu" do
        put :update, :id=>@menu.to_param, :menu=>{:name=>"Sniggles"}
        assert_redirected_to login_url
      end
      
      should "not be able to create a menu" do
        assert_no_difference "Menu.count" do
          post :create, :menu=>{:name=>"Sniggles", :shop_id=>@shop.to_param}
          assert_redirected_to login_url
        end
      end     
      
      should "not be able to delete a menu" do
        delete :destroy, :id => @menu.to_param
        assert_redirected_to login_url
      end
      
    end
    
    context "when logged in as an active user" do
      setup do
        @user = User.make(:active)
        login_as @user
      end

      should "not be able to edit the menu" do
        get :edit, :id => @menu.to_param
        assert_redirected_to root_path
      end

      should "not be able to update a menu" do
        put :update, :id=>@menu.to_param, :menu=>{:name=>"Sniggles"}
        assert_redirected_to root_path
      end
      
      should "not be able to create a menu" do
        assert_no_difference "Menu.count" do
          post :create, :menu=>{:name=>"Sniggles", :shop_id=>@shop.to_param}
          assert_redirected_to root_path
        end
      end     
      
      should "not be able to delete a menu" do
        delete :destroy, :id => @menu.to_param
        assert_redirected_to root_path
      end

    end
    
    context "when logged in as a manager of the shop" do
      setup do
        @manager = User.make(:active)
        @shop.work_contracts.make(:user=>@manager, :role=>'manager')
        assert @shop.save
        login_as @manager   
      end

      # should "be able to create a menu" do
      #   assert_difference "Menu.count", 1 do
      #     # get :new, :shop_id=>@shop.id
      #     # assert_template 'new'
      #     post :create, :menu=>{:name=>"Sniggles", :shop_id=>@shop.id}
      #     assert_redirected_to edit_menu_path(Menu.last)
      #   end
      # end     

      should "be able to edit menu" do
        get :edit, :id => @menu.to_param
        assert_template 'edit'
      end     
              
      should "be able to update a menu" do
        put :update, :id=>@menu.to_param, :menu=>{:name=>"Gumbys"}
        @menu.reload
        assert_redirected_to edit_shop_path(@shop)
        assert_equal "Gumbys", @menu.name
      end     
            
    end
    
    
    context "when logged in as an administrator" do
      setup do
        login_as_admin
      end
              
      should "be able to edit menu" do
        get :edit, :id => @menu.to_param
        assert_template 'edit'
      end     
              
      should "be able to update a menu" do
        put :update, :id=>@menu.to_param, :menu=>{:name=>"Sniggles"}
        @menu.reload
        assert_redirected_to edit_shop_path(@shop)
        assert_equal "Sniggles", @menu.name
      end     
              
      should "be able to create a menu" do
        assert_difference "Menu.count", 1 do
          post :create, :menu=>{:name=>"Sniggles"}
          assert_redirected_to edit_menu_path(Menu.last)
        end
      end     
              
      should "be able to delete a menu" do
        assert_difference "Menu.count", -1 do
          delete :destroy, :id => @menu.to_param
          assert_redirected_to edit_shop_path(@shop)
        end
      end
      
    end

  end

end

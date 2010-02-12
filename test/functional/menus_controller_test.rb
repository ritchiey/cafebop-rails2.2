require 'test_helper'

class MenusControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def self.getting_the_import_page
    context "Getting the import page" do
      setup do
        get :import
      end
      yield
    end
  end

  def self.posting_csv_menu_data_to_import_csv
    context "Posting CSV menu data to import_csv" do
      subject { "Some,CSV,Menu data" }
      setup do           
        post :import_csv, :menu_import=>{:prefix=>'thai', :data=>subject}
      end
      yield
    end
  end

  context "When not authenticated" do
    posting_csv_menu_data_to_import_csv {should_redirect_to("the login page") {login_path}}
    getting_the_import_page {should_redirect_to("the login page") {login_path}}
  end
  
  as admin do

    getting_the_import_page do
      should_not_set_the_flash
      should_render_template 'import' 
      should_render_with_layout
      should_respond_with :success
    end
    
    posting_csv_menu_data_to_import_csv do  
      before_should "expect call to import_csv" do
        Menu.expects('import_csv').with('thai', subject )
      end

      should_redirect_to("the list of menus") {menus_path}
    end
    
  end
  

  context "Given a shop with a menu" do
    setup do
      @shop = Shop.make
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

      should "be able to create a menu" do
        assert_difference "Menu.count", 1 do
          # get :new, :shop_id=>@shop.id
          # assert_template 'new'
          # MenusController.any_instance.stubs(:require_manager_or_admin).returns(:true)
          post :create, :menu=>{:name=>"Sniggles"}, :shop_id=>@shop.id
          assert_redirected_to edit_menu_path(Menu.last)
        end
      end     

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

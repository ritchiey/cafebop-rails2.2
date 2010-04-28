require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  test "uploading a background image" do  
    image_upload = fixture_file_upload('files/logo.png', 'image/png')
    post :create, :shop=>{:name=>"Test Shop", :header_background=>image_upload}
  end
  
  setup :activate_authlogic


  should "redirect to list of shops on search with no parameters" do
    get :search
    assert_redirected_to shops_path
  end

  context "With a shop" do
    setup do
      @permalink = "myshop"
      @shop = Shop.make_unsaved
      @shop.stubs(:permalink).returns(@permalink)
      @shop.stubs(:id).returns(12)
      Shop.stubs(:find).returns(@shop)
      Shop.stubs(:find_by_id_or_permalink).with(@permalink, anything).returns(@shop)
      controller.stubs(:current_subdomain).returns(@permalink)
    end
    
    context "which is community" do
      setup do
        @shop.stubs(:state).returns('community')
      end

      context "when unauthenticated" do
        

        should "not be able to update a shop's details" do
          put :update, :shop=>{:name=>"Sniggles"}
          assert_redirected_to login_url
        end 
      
      end
    end
      
    
    context "which is express" do
      setup do
        @shop.stubs(:state).returns('express')
      end

      context "in the subdomain for that shop" do
        setup do
          controller.stubs(:current_subdomain).returns(@permalink)
        end
      
        context "when unauthenticated" do

          should "not be able to edit shop" do
            get :edit
            assert_redirected_to login_url
          end

          should "not be able to update a shop's details" do
            put :update, :shop=>{:name=>"Sniggles"}
            assert_redirected_to login_url
          end
      
          context "creating a shop" do
            setup do
              controller.stubs(:current_subdomain).returns(nil)
              post :create, :shop=>{:name=>"Sniggles"}
            end
            before_should "call new on the model class and save the model" do
              Shop.expects(:new).with(any_parameters).once.returns(@shop)
              @shop.expects(:save).once.returns(true)
            end
            #should_redirect_to("show page") {new_shop_order_path(@shop)}
            should "be cool" do
            end
          end
          
          should "not be able to delete a shop" do
            delete :destroy
            assert_redirected_to login_url
          end
      
        end
    
        context "when logged in as an active user" do
          setup do
            @user = User.make(:active)
            login_as @user
          end

          should "not be able to edit shop" do
            get :edit
            assert_redirected_to new_shop_order_url(@shop)
          end

          should "not be able to update a shop" do
            put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
            assert_redirected_to new_shop_order_path(@shop)
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
            @manager = User.make_unsaved(:active)
            @shop.stubs(:is_manager?).with(@manager).returns(true)
            controller.expects(:current_user).at_least_once.returns(@manager)
          end

          should "be able to edit shop" do
            get :edit
            assert_template 'edit'
          end     
              
          context "updating a shop" do
            setup do
              put :update, :shop=>@change
            end
          
            before_should "update the shop model" do
              @change = {:name=>"Sniggles"}
              @shop.expects(:update_attributes).returns(true)
            end
            should_redirect_to("new order for shop") {new_shop_order_path(@shop)}
          end
   
        end
    
    
        context "when logged in as an administrator" do
          setup do
            admin = User.make_unsaved(:active)
            admin.stubs(:is_admin?).returns(true)
            controller.stubs(:current_user).returns(admin)
          end
      
          should "be able to edit shop" do
            get :edit
            assert_template 'edit'
          end     
        
          context "updating a shop" do
            setup do
              put :update, :shop=>@change
            end
          
            before_should "update the shop model" do
              @change = {:name=>"Sniggles"}
              @shop.expects(:update_attributes).returns(true)
            end
            should_redirect_to("new order for shop") {new_shop_order_path(@shop)}
          end
              
          context "deleting the shop" do
            setup do
              delete :destroy
            end

            before_should "call destroy on the model" do
              @shop.expects(:destroy).once
            end
            should_redirect_to('root') {root_path}
          end
      
        end
      end
    end
  end

  context "When logged in as an administrator" do
    setup do
      admin = User.make_unsaved(:active)
      admin.stubs(:is_admin?).returns(true)
      controller.stubs(:current_user).returns(admin)
    end

    context "creating a shop and specifying a manager email" do
      setup do
        @email = "bob@example.com"       
        @shop = stub do
          expects(:save).returns(true)
          expects(:to_param).at_least_once.returns("xxx")
        end
        @create_args = {:name=>"Sniggles", :manager_email=>@email}
        Shop.expects(:new).returns(@shop)
        post :create, :shop=>@create_args
      end

      should_redirect_to("new shop order") { new_shop_order_path(@shop)}
    end
  end

end

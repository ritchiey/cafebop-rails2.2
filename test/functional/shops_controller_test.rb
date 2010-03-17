require 'test_helper'

class ShopsControllerTest < ActionController::TestCase

  test "uploading a background image" do  
    image_upload = fixture_file_upload('files/logo.png', 'image/png')
    post :create, :name=>"Test Shop", :header_background=>image_upload
  end
  
  setup :activate_authlogic

  context "With a shop" do
    setup do
      @shop = Shop.make_unsaved
      @shop.stubs(:id).returns(12)
      Shop.stubs(:find).returns(@shop)
    end
    
    context "which is community" do
      setup do
        @shop.stubs(:state).returns('community')
      end

      context "when unauthenticated" do
      
        should "not be able to update a shop's details" do
          put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
          assert_redirected_to login_url
        end
        
        context "updating cuisines" do
          setup do
            put :update, :id=>@shop.to_param, :shop=>{:cuisine_ids=>[3,5]}
          end

          before_should "call update_attributes on shop" do
            @shop.expects(:update_attributes).once.returns(true)
          end
          
          should "be ok" do
          end
        end
        
      end

    end
      
    
    context "which is express" do
      setup do
        @shop.stubs(:state).returns('express')
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

        should "not be able to update a shop's details" do
          put :update, :id=>@shop.to_param, :shop=>{:name=>"Sniggles"}
          assert_redirected_to login_url
        end
      
        context "creating a shop" do
          setup do
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

      
        # context "if it's a community shop" do
        #   setup do
        #     @shop.stubs(:state).returns('community')
        #   end
        # 
        #   context "updating the franchise and cuisine" do
        #     setup do
        #       put :update, :id=>@shop.to_param, :shop=>{:cuisine_ids=>@cuisine.id}
        #     end
        #     
        #     before_should "create the appropriate shop_cuisine records" do
        #       @cuisine = Cuisine.make_unsaved
        #       @cuisine.stubs(:id=>6)
        #       ShopCuisine.expects(:create).once.with({:cuisine_id=>@cuisine.id, :shop_id=>@shop.id})
        #     end
        #   end
        #   
        # end
      
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
              
      
        context "deleting the shop" do
          setup do
            delete :destroy, :id => @shop.to_param
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

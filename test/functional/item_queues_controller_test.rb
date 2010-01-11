require 'test_helper'

class ItemQueuesControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "With a queue in an express shop" do
    setup do
      @shop = Shop.make
      @shop.transition_to('express')
      @shop.start_accepting_queued_orders!
      assert @shop.queues_in_shop_payments?
      @menu = @shop.menus.make
      @menu_item = @menu.menu_items.make
      @item_queue = ItemQueue.make(:shop=>@shop, :name=>"Pancakes")
      @manager = User.make(:active)
      @shop.work_contracts.make(:user=>@manager, :role=>'manager')
      @shop.reload
      assert @shop.is_manager?(@manager)
    end     
    
    context "as manager" do
      setup do
        login_as @manager
      end

      should "be able to create a new item_queue" do
        assert_difference "@shop.item_queues.count", 1 do
          post :create, :shop_id=>@shop.to_param, :item_queue=>{:name=>"barrista"}
        end
      end  

      should "be able to view the queue" do
        get :show, :id=>@item_queue.id
        assert_template :show
      end
            
      should "be able to get the current items in the queue" do
        get :current_items, :id=>@item_queue.id
        assert_response :success
      end

      should "be able to update the item_queue" do
        assert_difference "ItemQueue.name_eq('barry').count", 1 do
          put :update, :id=>@item_queue.id, :item_queue=>{:name=>"barry"}
          assert_redirected_to edit_shop_path(@shop)
        end
      end

      should "be able to delete the item_queue" do
        assert_difference "ItemQueue.count", -1 do
          delete :destroy, :id=>@item_queue.id
          assert_redirected_to edit_shop_path(@shop)
        end
      end

      should "be able to start item_queue" do
        @item_queue.stop!
        assert !@item_queue.active
        put :start, :id=>@item_queue.id
        @item_queue.reload
        assert @item_queue.active
      end
      
      should "be able to stop the item_queue" do
        @item_queue.start!
        assert @item_queue.active
        put :stop, :id=>@item_queue.id
        @item_queue.reload
        assert !@item_queue.active
      end
    end

    context "as a staff member" do
      setup do
        @staff = User.make(:active)
        @shop.work_contracts.make(:user=>@staff, :role=>'staff')
        assert @shop.is_staff?(@staff)  
        assert !@shop.is_manager?(@staff)  
        login_as @staff
      end   
      
      
      should "not be able to create a new item_queue" do
        assert_no_difference "@shop.item_queues.count" do
          post :create, :shop_id=>@shop.to_param, :item_queue=>{:name=>"barrista"}
        end
      end

      should "not be able to update the item_queue" do
        assert_no_difference "ItemQueue.name_eq('barry').count" do
          put :update, :id=>@item_queue.id, :item_queue=>{:name=>"barry"}
          assert_redirected_to new_shop_order_path(@shop)
        end
      end

      should "be able to view the queue" do
        get :show, :id=>@item_queue.id
        assert_template :show
      end
            
      should "be able to get the current items in the queue" do
        get :current_items, :id=>@item_queue.id
        assert_response :success
      end

      should "not be able to delete the item_queue" do
        assert_no_difference "ItemQueue.count" do
          delete :destroy, :id=>@item_queue.id
          assert_redirected_to new_shop_order_path(@shop)
        end
      end

      should "be able to start item_queue" do
        @item_queue.stop!
        assert !@item_queue.active
        put :start, :id=>@item_queue.id
        @item_queue.reload
        assert @item_queue.active
      end

      should "be able to stop the item_queue" do
        @item_queue.start!
        assert @item_queue.active
        put :stop, :id=>@item_queue.id
        @item_queue.reload
        assert !@item_queue.active
      end
    end

    context "as an active user" do
      setup do
        @user = User.make(:active)
        login_as @user
      end


      should "not be able to create a new item_queue" do
        assert_no_difference "@shop.item_queues.count" do
          post :create, :shop_id=>@shop.to_param, :item_queue=>{:name=>"barrista"}
        end
      end

      should "not be able to update the item_queue" do
        assert_no_difference "ItemQueue.name_eq('barry').count" do
          put :update, :id=>@item_queue.id, :item_queue=>{:name=>"barry"}
          assert_redirected_to new_shop_order_path(@shop)
        end
      end                      

      should "not be able to view the queue" do
        get :show, :id=>@item_queue.id
        assert_response :redirect
      end

      should "not be able to get the current items in the queue" do
        get :current_items, :id=>@item_queue.id
        assert_response :redirect
      end

      should "not be able to delete the item_queue" do
        assert_no_difference "ItemQueue.count" do
          delete :destroy, :id=>@item_queue.id
          assert_redirected_to new_shop_order_path(@shop)
        end
      end

      should "not be able to start item_queue" do
        @item_queue.stop!
        assert !@item_queue.active
        put :start, :id=>@item_queue.id
        @item_queue.reload
        assert !@item_queue.active
      end
      
      should "not be able to stop the item_queue" do
        @item_queue.start!
        assert @item_queue.active
        put :stop, :id=>@item_queue.id
        @item_queue.reload
        assert @item_queue.active
      end
    end
    
    context "as an unauthenticated user" do
      setup do
        logout
      end

      should "not be able to create a new item_queue" do
        assert_no_difference "@shop.item_queues.count" do
          post :create, :shop_id=>@shop.to_param, :item_queue=>{:name=>"barrista"}
        end
      end

      should "not be able to update the item_queue" do
        assert_no_difference "ItemQueue.name_eq('barry').count" do
          put :update, :id=>@item_queue.id, :item_queue=>{:name=>"barry"}
          assert_redirected_to new_shop_order_path(@shop)
        end
      end                      

      should "not be able to view the queue" do
        get :show, :id=>@item_queue.id
        assert_response :redirect
      end

      should "not be able to get the current items in the queue" do
        get :current_items, :id=>@item_queue.id
        assert_response :redirect
      end

      should "not be able to delete the item_queue" do
        assert_no_difference "ItemQueue.count" do
          delete :destroy, :id=>@item_queue.id
          assert_redirected_to new_shop_order_path(@shop)
        end
      end

      should "not be able to start item_queue" do
        @item_queue.stop!
        assert !@item_queue.active
        put :start, :id=>@item_queue.id
        @item_queue.reload
        assert !@item_queue.active
      end
      
      should "not be able to stop the item_queue" do
        @item_queue.start!
        assert @item_queue.active
        put :stop, :id=>@item_queue.id
        @item_queue.reload
        assert @item_queue.active
      end
    end
    
  end
end

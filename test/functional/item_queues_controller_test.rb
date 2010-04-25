require 'test_helper'

class ItemQueuesControllerTest < ActionController::TestCase
  setup :activate_authlogic

  context "With a queue in a shop that accepts queued orders" do
    setup do
      @shop = Shop.make_unsaved
      Shop.stubs(:find_by_id_or_permalink).returns(@shop)
      @shop.stubs(:accepts_queued_orders?).returns(true)
      @shop.stubs(:queues_in_shop_payments?).returns(true)
      @item_queue = ItemQueue.make_unsaved(:name=>"Pancakes")
      @item_queue.stubs(:shop).returns(@shop)
      @item_queue.stubs(:id).returns(14)
      ItemQueue.stubs(:find).returns(@item_queue)
    end     
    
    context "as someone who can access queues" do
      setup do
        @manager.expects(:can_access_queues_of?).with(@shop).returns(true)
        @manager.expects(:can_manage_queues_of?).with(@shop).returns(true)
        controller.stubs(:current_user).returns(@manager)
      end

      context "creating an item_queue" do
        setup do
          post :create, :shop_id=>@shop.to_param, :item_queue=>{:name=>"barrista"}
        end

        before_should "build and save the item_queue" do
          @shop.item_queues.expects(:build).returns(@queue)
          @queue.expects(:save).returns(true)
        end
      end
      
      context "viewing the queue" do
        setup do
          get :show, :id=>@item_queue.id
        end                          
        should_render_template :show
      end
            
      context "getting the current items in the queue" do
        setup do
          get :current_items, :id=>@item_queue.id
        end
        should_render_template "current_items"
        should_assign_to(:queue) {@queue}
      end
      
      

      context "updating the item_queue" do
        setup do
          put :update, :id=>@item_queue.id, :item_queue=>{:name=>"barry"}
        end

        before_should "call update on model" do
          @item_queue.expects(:update_attributes)
        end
        
        should_redirect_to("edit page for shop") {edit_shop_path(@shop)}
      end
      
      context "deleting the queue" do
        setup do
          delete :destroy, :id=>@item_queue.id
        end

        before_should "" do
          @item_queue.expects(:destroy)
        end
        should_redirect_to("edit page for shop") {edit_shop_path(@shop)}
      end
      
      context "starting the item_queue" do
        setup do
          put :start, :id=>@item_queue.id
        end

        before_should "call start! on the item_queue" do
          @item_queue.expects(:start!)
        end
      end

      context "stopping the item_queue" do
        setup do
          put :stop, :id=>@item_queue.id
        end

        before_should "call stop! on the item_queue" do
          @item_queue.expects(:stop!)
        end
      end
      
    end

    context "as someone who can access but not manage the queue" do
      setup do
        @manager.expects(:can_access_queues_of?).with(@shop).returns(true)
        @manager.expects(:can_manage_queues_of?).with(@shop).returns(false)
        controller.stubs(:current_user).returns(@manager)
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

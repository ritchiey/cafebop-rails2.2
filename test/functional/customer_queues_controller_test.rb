require 'test_helper'

# class CustomerQueuesControllerTest < ActionController::TestCase
#   def test_index
#     get :index
#     assert_template 'index'
#   end
#   
#   def test_show
#     get :show, :id => CustomerQueue.first
#     assert_template 'show'
#   end
#   
#   def test_new
#     get :new
#     assert_template 'new'
#   end
#   
#   def test_create_invalid
#     CustomerQueue.any_instance.stubs(:valid?).returns(false)
#     post :create
#     assert_template 'new'
#   end
#   
#   def test_create_valid
#     CustomerQueue.any_instance.stubs(:valid?).returns(true)
#     post :create
#     assert_redirected_to customer_queue_url(assigns(:customer_queue))
#   end
#   
#   def test_edit
#     get :edit, :id => CustomerQueue.first
#     assert_template 'edit'
#   end
#   
#   def test_update_invalid
#     CustomerQueue.any_instance.stubs(:valid?).returns(false)
#     put :update, :id => CustomerQueue.first
#     assert_template 'edit'
#   end
#   
#   def test_update_valid
#     CustomerQueue.any_instance.stubs(:valid?).returns(true)
#     put :update, :id => CustomerQueue.first
#     assert_redirected_to customer_queue_url(assigns(:customer_queue))
#   end
#   
#   def test_destroy
#     customer_queue = CustomerQueue.first
#     delete :destroy, :id => customer_queue
#     assert_redirected_to customer_queues_url
#     assert !CustomerQueue.exists?(customer_queue.id)
#   end
# end

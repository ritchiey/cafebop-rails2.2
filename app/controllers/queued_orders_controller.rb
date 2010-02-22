class QueuedOrdersController < ApplicationController
  
  before_filter :get_instance
  before_filter :only_if_can_access_queue
  
  def show
    respond_to do |format|
      format.json {
        render :json=>@order.to_json(
          :methods=>[:grand_total, :summarized_order_items, :effective_name],
          :include=>{:order_items=>{:only=>[:quantity, :description, :id], :methods=>[:cost]}}
        )
      }
    end
  end
  
private

  def only_if_can_access_queue
    unauthorized unless current_user and @order and
                current_user.can_access_queues_of?(@order.shop)
  end
  
  def get_instance
    @order = Order.find(params[:id], :include=>[:shop])
  end
  
end

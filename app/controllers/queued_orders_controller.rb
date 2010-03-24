class QueuedOrdersController < ApplicationController
  
  before_filter :require_login
  before_filter :get_instance
  before_filter :only_if_can_access_queue
  
  def show
    respond_to do |format|
      format.json {
        render :json=>@order.to_json(
          :only=>[:id, :notes, :name, :state],
          :methods=>[:grand_total, :summary, :summarized_order_items, :effective_name, :queued_at_utc, :reputation_s] #,
          #:include=>{:order_items=>{:only=>[:state, :quantity, :description, :id], :methods=>[:cost]}}
        )
      }
    end
  end
  
  def make_all_items
    @order.make_all_items!
    respond_to do |format|
      format.html {redirect_to @order}
      format.mobile {redirect_to @order}
      format.json {render :json=>true}
    end
  end
  
  def no_show
    @order.no_show!
    respond_to do |format|
      format.html {redirect_to @order}
      format.mobile {redirect_to @order}
      format.json {render :json=>true}
    end
  end
  
  def deliver
    @order.deliver!
    respond_to do |format|
      format.html {redirect_back_or_default}
      format.json do
        cq = @order.customer_queue
        render :json=>(cq ? cq.current_orders.count : 0).to_json
      end
    end
  end
  
  
  
  def cancel
    @order.cancel!
    respond_to do |format|
      format.html {redirect_to @order}
      format.mobile {redirect_to @order}
      format.json {render :json=>true}
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

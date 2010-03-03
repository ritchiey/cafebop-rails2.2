class CustomerQueuesController < QueuesController

  before_filter :shop_from_permalink, :only => [:new, :create]
  before_filter :queue_from_id, :except => [:new, :create]
  before_filter :require_manager, :except => [:show, :start, :stop, :current_items]
  before_filter :require_staff, :only => [:show, :start, :stop, :current_items]


  def new
    @queue = @shop.customer_queues.build
  end                                
  
  def create
    @queue = @shop.customer_queues.build(params[:customer_queue])
    if @queue.save
      flash[:notice] = "Queue created."
      redirect_to edit_shop_path(@shop)
    else
      render :action=>:new
    end
  end
       
  def update       
    unless @queue.update_attributes(params[:customer_queue])
      flash[:error] = "Couldn't update customer queue"
    end
    redirect_to edit_shop_path(@shop)
  end

  def destroy
    @queue.destroy
    flash[:notice] = "Successfully destroyed queue"
    redirect_to edit_shop_path(@shop)
  end


  def show
    @orders = @queue.current_orders
    @queue.shop.accepts_queued_orders? or
    flash.now[:error] = "Queuing for #{@queue.shop.name} is currently disabled. You won't receive any orders."
    respond_to do |format|
      format.html
      format.mobile
      format.json do
        render :json=>@queue.to_json(:only=>[:name, :id], :include=>{
          :current_orders=>{
            :only=>[:id, :notes, :name, :state],
            :methods=>[:grand_total, :summarized_order_items, :summary],
            :include=>{:user=>{:only=>[:name]}}
          }
        })
      end
    end
  end

  def current_orders
    @orders = @queue.current_orders
    render :partial=>"current_orders"
  end

  def start           
    @queue.start!
    render :partial=>'status'
  end

  def stop
    @queue.stop!
    render :partial=>'status'
  end


private

  def model_class
    CustomerQueue
  end

  def queue_from_id
    @queue = model_class.find(params[:id], :include=>[:shop, {:orders=>[{:child_orders=>:order_items}, :order_items]}])
    @shop = @queue.shop
  end
end

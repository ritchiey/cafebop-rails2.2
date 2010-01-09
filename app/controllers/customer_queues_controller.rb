class CustomerQueuesController < QueuesController

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
    @queue.shop.accepts_queued_orders? or
    flash.now[:error] = "Queuing for #{@queue.shop.name} is currently disabled. You won't receive any orders."
  end

  def current_orders
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

end

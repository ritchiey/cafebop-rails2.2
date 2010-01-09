class ItemQueuesController < QueuesController

  before_filter :shop_from_permalink, :only => [:new, :create]
  before_filter :queue_from_id, :except => [:new, :create]
  before_filter :require_manager, :except => [:show, :start, :stop, :current_items]
  before_filter :require_staff, :only => [:show, :start, :stop, :current_items]

  def new
    @queue = @shop.item_queues.build
  end                                
  
  def create
    @queue = @shop.item_queues.build(params[:item_queue])
    if @queue.save
      flash[:notice] = "Queue created."
      redirect_to edit_shop_path(@shop)
    else
      render :action=>:new
    end
  end
       
  def update       
    unless @queue.update_attributes(params[:item_queue])
      flash[:error] = "Couldn't update item queue"
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

  def current_items
    render :partial=>"current_items"
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
    ItemQueue
  end

end


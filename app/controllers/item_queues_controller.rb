class ItemQueuesController < ApplicationController
     
  def new
    @shop = Shop.find(params[:shop_id])
    @item_queue = @shop.item_queues.build
  end                                
  
  def create
    @shop = Shop.find(params[:shop_id])
    @item_queue = @shop.item_queues.build(params[:item_queue])
    if @item_queue.save
      flash[:notice] = "Queue created."
      redirect_to edit_shop_path(@shop)
    else
      render :action=>:new
    end
  end

  def show
    @item_queue = ItemQueue.find(params[:id])
  end

  def current_items
    @item_queue = ItemQueue.find(params[:id])
    respond_to do |wants|
      wants.html { render :partial=>"current_items" }
    end
  end

end

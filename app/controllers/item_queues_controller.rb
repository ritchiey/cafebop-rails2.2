class ItemQueuesController < ApplicationController
  
  before_filter :shop_from_permalink, :only => [:new, :create]
  before_filter :item_queue_from_id, :except => [:new, :create]
     
  def new
    @item_queue = @shop.item_queues.build
  end                                
  
  def create
    @item_queue = @shop.item_queues.build(params[:item_queue])
    if @item_queue.save
      flash[:notice] = "Queue created."
      redirect_to edit_shop_path(@shop)
    else
      render :action=>:new
    end
  end

  def show
  end

  def current_items
    render :partial=>"current_items"
  end

  def start
    @item_queue.start!
    render :partial=>'status'
  end

  def stop
    @item_queue.stop!
    render :partial=>'status'
  end

end


private

  def shop_from_permalink
    @shop = Shop.find_by_permalink(params[:shop_id])
  end

  def item_queue_from_id
    @item_queue = ItemQueue.find(params[:id])
    @shop = @item_queue.shop
  end
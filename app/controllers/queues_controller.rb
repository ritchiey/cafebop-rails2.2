class QueuesController < ApplicationController

  before_filter :shop_from_permalink, :only => [:new, :create]
  before_filter :queue_from_id, :except => [:new, :create]
  before_filter :require_manager, :except => [:show, :start, :stop, :current_items]
  before_filter :require_staff, :only => [:show, :start, :stop, :current_items]

protected
  

  def shop_from_permalink
    @shop = Shop.find_by_permalink(params[:shop_id])
  end

  def queue_from_id
    @queue = model_class.find(params[:id])
    @shop = @queue.shop
  end
  
  def require_manager
    if !current_user || !@shop.is_manager?(current_user)
      redirect_to new_shop_order_path(@shop)
    end
  end
  
  def require_staff  
    if !current_user || !@shop.is_staff?(current_user)
      redirect_to new_shop_order_path(@shop)
    end
  end
  
end
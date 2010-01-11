class QueuesController < ApplicationController


protected
  

  def shop_from_permalink
    @shop = Shop.find_by_id_or_permalink(params[:shop_id])
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
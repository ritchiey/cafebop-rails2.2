class QueuesController < ApplicationController


protected
  

  # def shop_from_permalink
  #   @shop = Shop.find_by_id_or_permalink(params[:shop_id])
  # end
  # 
  
  def require_manager
    unless current_user and current_user.can_manage_queues_of?(@shop)
      redirect_to new_shop_order_path(@shop)
    end
  end
  
  def require_staff  
    unless current_user and current_user.can_access_queues_of?(@shop)
      redirect_to new_shop_order_path(@shop)
    end
  end
  
end
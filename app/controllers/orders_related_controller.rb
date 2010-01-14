class OrdersRelatedController < ApplicationController
  
protected

  def order_from_id
    @order = Order.find(params[:id])  
    @shop = @order.shop
  end

  def order_with_items_from_id
    @order = Order.find(params[:id], :include=>:order_items)
    @shop = @order.shop
  end

  def only_if_staff_or_admin
    unless current_user and (current_user.is_admin? or @shop.is_staff?(current_user))
      flash[:error] = "Ummm... no."
      redirect_to new_shop_order_path(shop)
    end
  end
    

end
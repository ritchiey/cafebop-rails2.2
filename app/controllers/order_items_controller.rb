class OrderItemsController < ApplicationController
  
  before_filter :find_order_item
  before_filter :only_if_staff
  
  def make
    @order_item.make!
  end


  def find_order_item
    @order_item = OrderItem.find(params[:id])
  end
  
  def only_if_staff
    order = @order_item.order
    shop = order.shop
    unless shop.is_staff?(current_user)
      flash[:error] = "Ummm... no."
      redirect_to new_shop_order_path(shop)
    end
  end
end

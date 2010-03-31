class OrderItemsController < ApplicationController
  
  before_filter :find_order_item, :except=>[:index]
  before_filter :only_if_staff, :except=>[:index]
  
  make_resourceful do
    actions :index, :show
    belongs_to :order
  end
  
  
  def find_order_item
    @order_item = OrderItem.find(params[:id])
  end
  
  def only_if_staff
    order = @order_item.order
    shop = order.shop
    unless current_user and current_user.can_access_queues_of?(shop)
      flash[:error] = "Ummm... no."
      redirect_to new_shop_order_path(shop)
    end
  end

end

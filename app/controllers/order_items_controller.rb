class OrderItemsController < ApplicationController
  
  def make
    @order_item = OrderItem.find(params[:id])
    @order_item.make!
  end
end

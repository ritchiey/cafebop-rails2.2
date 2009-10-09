class OrderItemsController < ApplicationController
  
  def make
    @order_item = OrderItem.find(params[:id])
    @order_item.make!
    respond_to do |wants|
      wants.rjs
    end
  end
end

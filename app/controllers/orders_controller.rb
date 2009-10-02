class OrdersController < ApplicationController

  def index
    @orders = Order.find :all
  end                        
  
  def show
    @order = Order.find(params[:id])
  end

  def new
    @shop = Shop.find(params[:shop_id])
    @order = @shop.orders.build
  end                  
  
  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "Successfully created order"
      redirect_to orders_path
    else                     
      render :action=>'place'
    end
  end
end

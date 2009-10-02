class OrdersController < ApplicationController

  def index
    @orders = Order.find :all
  end                        
  
  def show
    @order = Order.find(params[:id])
  end

  def new_for_shop
    #TODO find appropriate shop
    @shop = Shop.find(params[:id])
    @order = Shop.order.build
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

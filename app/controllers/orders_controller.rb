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
    @order = Order.new(params[:order].merge(:shop_id=>params[:shop_id]))
    
    if @order.save
      redirect_to @order
    else                     
      render :action=>'place'
    end
  end   
  
  def edit
    @order = Order.find(params[:id])
    @shop = @order.shop
  end                                  
  
  def confirm
    @order = Order.find(params[:id])
    @order.confirm!
    @order.save
    redirect_to @order
  end
  
end

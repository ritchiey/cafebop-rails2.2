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
    if params[:order]
      @order = Order.new(params[:order].merge(:shop_id=>params[:shop_id]))
      if @order.save
        redirect_to @order
      else
        render :action=>'place'
      end
    else
       flash[:error] = "You must select at least one item"
       redirect_to new_shop_order_path
    end


  end

  def edit
    @order = Order.find(params[:id])
    @shop = @order.shop
  end

  def pay_in_shop
    @order = Order.find(params[:id])
    @order.pay_in_shop!
    @order.save
    redirect_to @order
  end

  def summary
    @order = Order.find(params[:id])
    render :partial=>'summary'
  end

  # Authorize payment through Paypal
  def pay_paypal
    @order = Order.find(params[:id])
    @order.request_paypal_authorization!
    #TODO: Redirect appropriately to Paypal
  end

end


class OrdersController < ApplicationController

  def index
    @orders = Order.find :all
  end

  def show
    @order = Order.find(params[:id])
    @shop = @order.shop
  end

  def new
    @shop = Shop.find(params[:shop_id])
    @order = @shop.orders.build
  end

  def create
    if params[:order]
      @order = Order.new(params[:order].merge(:shop_id=>params[:shop_id]))
      if @order.save
        redirect_to order_path(@order)
      else        
        flash[:error] = @order.errors.full_messages.collect{|m| m}.join('. ')
        redirect_to new_shop_order_path
      end
    else
       flash[:error] = "You must select at least one menu item"
       redirect_to new_shop_order_path
    end


  end

  def edit
    @order = Order.find(params[:id])
    @shop = @order.shop
  end
  
  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(params[:order])
      redirect_to shop_order_path(@order.shop_id, @order)
    else
      flash[:error] = "Unable to save changes"
      redirect_to edit_shop_order_path(@order.shop_id, @order)
    end
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


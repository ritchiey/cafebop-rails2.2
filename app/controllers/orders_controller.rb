class OrdersController < ApplicationController

  def index
    @orders = Order.find :all
  end

  def show
    @order = Order.find(params[:id])
    @shop = @order.shop
  end

  def new
    @shop = Shop.find(params[:shop_id], :include=>[:operating_times, {:menus=>{:menu_items=>[:sizes,:flavours]}}])
    @order = @shop.orders.build
  end

  def create
    if params[:order]
      @order = Order.new(params[:order].merge(:shop_id=>params[:shop_id], :user=>current_user))
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
      redirect_to order_path(@order)
    else
      flash[:error] = "Unable to save changes"
      redirect_to edit_order_path(@order)
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

  # Display the invitation form to invite others
  def invite
    @order = Order.find(params[:id])
  end

  # Accept an invite that we were sent
  def accept
    @order = Order.find(params[:token])
    @order.accept!
    redirect_to :action=>:edit
  end

  # Decline an invite that we were sent
  def decline
    @order = Order.find(params[:token])
    @order.decline!
    flash[:notice] = "Thanks for letting us know. Maybe next time."
    redirect_to root_path
  end

end


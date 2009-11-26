OrderObserver.instance

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
    @shop = Shop.find(params[:shop_id])
    if @shop and params[:order]
      logger.info "Creating order for user '#{current_user}'"
      @order = @shop.orders.build(params[:order].merge(:user_id=>current_user.andand.id))
      if @order.save
        logger.info "Created order for user '#{@order.user}'"
        redirect_to order_path(@order)
      else        
        flash[:error] = @order.errors.full_messages.collect{|m| m}.join('. ')
        logger.error @order.errors.full_messages.collect{|m| m}.join('. ')
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
    @order = Order.find_by_perishable_token(params[:token])
    if @order.invited?
      # authenticate the user
      login_as @order.user
      @order.accept!
      redirect_to edit_order_path(@order)
    elsif @order.declined?
      flash[:notice] = "Sorry, you already declined that invitation"
      redirect_to root_path
    else
      flash[:notice] = "Sorry, you can only accept an invitation once"
      redirect_to root_path
    end
  end

  # Decline an invite that we were sent
  def decline
    @order = Order.find_by_perishable_token(params[:token])
    if @order.invited?
      login_as @order.user
      @order.decline!
    end
    flash[:notice] = "Thanks for letting us know. Maybe next time."
    redirect_to root_path
  end

  def confirm
    @order = Order.find(params[:id])
    @order.confirm!
    @order.save
    redirect_to @order  end

end


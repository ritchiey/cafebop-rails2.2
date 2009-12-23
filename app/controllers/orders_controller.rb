OrderObserver.instance
UserObserver.instance

class OrdersController < ApplicationController

  around_filter :with_order_from_token, :only => [:accept, :decline]
  before_filter :order_with_items_from_id, :only => [:show, :edit, :summary, :status_of_pending]
  before_filter :order_from_id, :only=>[:update, :pay_in_shop, :pay_paypal, :invite, :closed, :confirm, :close, :destroy]
  before_filter :only_if_mine, :except => [:new, :create, :accept, :decline, :index, :destroy]
  before_filter :require_admin_rights, :only => [:index, :destroy]
  before_filter :unless_invitation_closed, :only=>[:show, :edit]
  before_filter :login_transparently, :only => [:update]
  before_filter :create_friendship, :only=>[:update]

  after_filter :mark_as_mine, :only=>[:create, :accept]

  def index
    @orders = Order.find :all
  end

  def show  
    @shop = @order.shop
  end

  def new
    @shop = Shop.find_by_permalink(params[:shop_id], :include=>[:operating_times, {:menus=>{:menu_items=>[:sizes,:flavours]}}])
    @order = @shop.orders.build
  end

  def create
    @shop = Shop.find_by_permalink(params[:shop_id])
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
    @shop = @order.shop
  end


  def update  
    restore_from session, @order
    @order.attributes = params[:order]
    persist_to session, @order
    @order.user ||= current_user
    if @order.save # updated attributes earlier
      redirect_to case @order.page
      when 'inviting': invite_order_path(@order)
      else order_path(@order)
      end
    else
      flash[:error] = "Unable to save changes"
      redirect_to edit_order_path(@order)
    end
  end  

  def pay_in_shop
    @order.pay_in_shop!
    @order.save
    redirect_to @order
  end

  def summary
    @shop = @order.shop
    render :partial=>'summary'
  end

  def status_of_pending
    @shop = @order.shop
  end

  def status_of_queued
    @shop = @order.shop
  end

  # Authorize payment through Paypal
  def pay_paypal
    response = @order.request_paypal_authorization!(
      :returnUrl=>order_url(@order),
      :cancelUrl=>order_url(@order)
      )
    if @order.pending_paypal_auth?
      redirect_to @order.paypal_auth_url(response)
    end
  end
  

  # Display the invitation form to invite others
  def invite    
    current_user and @order.user ||= current_user
    restore_from session, @order
    @order.page = 'inviting'
    persist_to session, @order
    @order.page = 'summary' # If the form includes this field, it will override the version in the session
    # If user's already specified email pre-populate login form
    @user_session = UserSession.new(:email=>@order.user_email) if !authenticated? && @order.user_email
  end


  # Accept an invite that we were sent
  def accept
    if @order.invited?
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
    if @order
      @order.decline!
    end
    flash[:notice] = "Thanks for letting us know. Maybe next time."
    redirect_to root_path
  end

  def close
    @order.close_early!
    redirect_to @order
  end
  
  # User tried to accept or confirm their order but parent had already closed
  def closed
  end

  def confirm
    @order.confirm!
    @order.save
    redirect_to @order
  end

  def destroy
    @order.destroy
    redirect_to orders_path
  end
    

private

  def order_from_id
    @order = Order.find(params[:id])
  end

  def order_with_items_from_id
    @order = Order.find(params[:id], :include=>:order_items)
  end
  
  def create_friendship
    if params[:commit] == "Add"
      if current_user and fp = params[:friendship]
        if current_user.friendships.create(fp)  
          #Make sure the new friend is selected to be invited
          @order.attributes = params[:order]
          @order.invited_user_attributes << fp[:friend_email]
          persist_to session, @order
        end
      end
      redirect_to invite_order_path(@order)
    end
  end
  
  def unless_invitation_closed
    if @order.invite_closed?
      render :action=>:closed if @order.invite_closed?
    end
  end        
  
  def with_order_from_token
    @order = Order.find_by_perishable_token(params[:token])
    if @order
      login_as @order.user if @order.invited?
      yield
    end
  end
  
  
  # An order is considered yours if you are authenticated as order.user
  # or if the you have the perishable_token of that order in your session.
  def only_if_mine
    unless @order.mine?(current_user, session[:order_token])
      flash[:error] = "Whoa! That's not yours."
      redirect_to new_shop_order_path(@order.shop)
    end
  end
  
  def mark_as_mine
    session[:order_token] = @order.perishable_token
  end
end


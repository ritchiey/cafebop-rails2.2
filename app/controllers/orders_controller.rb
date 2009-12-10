OrderObserver.instance
UserObserver.instance

class OrdersController < ApplicationController

  before_filter :order_from_id, :except=>[:index, :new, :create, :accept, :decline, :show]
  before_filter :login_transparently, :only => [:update]
  before_filter :create_friendship, :only=>[:update]


  def index
    @orders = Order.find :all
  end

  def show  
    @order = Order.find(params[:id], :include=>:order_items)
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
      redirect_to @order.inviting ? invite_order_path(@order) : order_path(@order)
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
    render :partial=>'summary'
  end

  # Authorize payment through Paypal
  def pay_paypal
    @order.request_paypal_authorization!
    #TODO: Redirect appropriately to Paypal
  end

  # Display the invitation form to invite others
  def invite 
    restore_from session, @order
    @order.inviting = true
    persist_to session, @order
    # If user's already specified email pre-populate login form
    @user_session = UserSession.new(:email=>@order.user_email) if !authenticated? && @order.user_email
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
    @order.confirm!
    @order.save
    redirect_to @order
  end


private

  def order_from_id
    @order = Order.find(params[:id])
  end

  # def login_transparently
  #   if !current_user && params[:user_session]
  #     email = params[:user_session][:email] 
  #     user = User.email_is(email).first
  #     if user
  #       if user.active?
  #         if params[:user_session][:password]
  #           @user_session = UserSession.new(params[:user_session])
  #           if @user_session.save
  #             @order.andand.set_user(user)
  #           else
  #             flash[:error] = "Invalid email or password"
  #           end
  #         else # active user but no password specified     
  #           flash[:email] = user.email # the view should detect the email and just ask for the password
  #         end
  #       else # exists but not active
  #         Notifications.deliver_activate(user)
  #         flash[:notice] = "An account activation email has been sent to '#{user.email}'. Please check your inbox to continue."
  #         @order.andand.set_user(user)
  #       end
  #     else # new user
  #       user = User.create_without_password(:email=>email)
  #       flash[:notice] = "An account activation email has been sent to '#{user.email}'. Please check your inbox to continue."
  #       @order.andand.set_user(user)
  #     end
  #     redirect_to :back
  #   end
  # end
    
  
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
end


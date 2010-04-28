OrderObserver.instance
UserObserver.instance

class OrdersController < OrdersRelatedController

  around_filter :with_order_from_token, :only => [:accept, :decline]
  # before_filter :order_with_items_from_id, :only => [:show, :summary, :status_of_pending, :status_of_queued]
  # before_filter :order_from_id, :only=>[:update, :send_invitations, :place, :cancel_paypal, :invite, :closed, :confirm, :close, :destroy, :deliver, :get_name_for]
  # before_filter :order_with_items_and_shop_menu_from_id, :only => [:edit]
  
  before_filter :cookies_required, :except => [:cookies_test, :new]
  before_filter :include_menus_with_shop, :only => [:new, :edit]
  before_filter :fetch_shop, :except => [:accept, :decline]
  before_filter :include_items_with_order, :only => [:show, :summary, :status_of_pending, :status_of_queued]
  before_filter :fetch_order, :except =>  [:accept, :decline, :new, :create]
  
  
  before_filter :check_paypal_status, :only => [:show]
  before_filter :only_if_mine, :except => [:new, :create, :accept, :decline, :index, :destroy, :deliver]
  before_filter :only_if_staff_or_admin, :only=>[:deliver]
  before_filter :require_admin_rights, :only => [:destroy, :index]
  before_filter :unless_invitation_closed, :only=>[:show, :edit] #TODO: :update?, :confirm?
  before_filter :only_if_pending, :only=>[:edit, :invite]
  before_filter :login_transparently, :only => [:send_invitations]
  before_filter :create_friendship, :only=>[:send_invitations]
  before_filter :only_if_shop_monitoring_queues, :only => [:place, :pay_in_shop, :pay_paypal]
  after_filter :mark_as_mine, :only=>[:create, :accept]

  def show
    respond_to do |format|
      format.mobile
      format.html
      format.json do
        render :json=>@order.to_json(
          :methods=>[:grand_total, :summarized_order_items, :effective_name],
          :include=>{:order_items=>{:only=>[:quantity, :description, :id], :methods=>[:cost]}}
        )
      end
    end
  end

  def new
    @order = @shop.orders.build
    current_user and @order.user = current_user
  end

  def create
    @shop = Shop.find_by_id_or_permalink(params[:shop_id])
    if @shop and params[:order]
      logger.info "Creating order for user '#{current_user}'"
      @order = @shop.orders.build(params[:order].merge(:user_id=>current_user.andand.id))
      if @order.save
        logger.info "Created order for user '#{@order.user}'"
        check_delivery_details
      else        
        wrangle_order_errors
        redirect_to new_shop_order_path
      end
    else
       flash[:error] = "You must select at least one menu item"
       redirect_to new_shop_order_path
    end
  end

                              
  def edit
  end

  def update
    if @order.update_attributes(params[:order])
      check_delivery_details
    else
      flash[:error] = "Unable to save changes"
      redirect_to edit_order_path(@order)
    end
  end  

  def get_name_for
  end

  #Determines from input which payment method
  def place          
    case (params[:commit])
    when 'Pay In Shop': pay_in_shop
    else # Pay PayPal is an image submit tag and doesn't have a value
      pay_paypal
    end
  end


  def pay_in_shop
    if @shop.queues_in_shop_payments?
      # Must be authenticated
      unless current_user
        flash[:notice] = "You'll need a Cafebop account place your order."
        redirect_to signup_path(:order_id=>@order.id)
        return
      end
    end
    @order.pay_in_shop!
    redirect_to @order
  end            


  def pay_paypal
    @order.pay_paypal!
    recipients = [{:email => @order.paypal_recipient,
                   :amount => sprintf("%0.2f", @order.grand_total_with_fees),
                   :invoice_id => @order.id.to_s
                  }       
                 ]      
    options = {
      :currency_code => 'AUD',
      :return_url => order_url(@order),
      :cancel_url => cancel_paypal_order_url(@order),
      :notify_url => payment_notifications_url,
      :receiver_list => recipients
    }           
    response = gateway.pay(options)
    @order.paypal_paykey = response.paykey
    @order.save!
    redirect_to response.redirect_url_for
  end   
  
  # Not happy about this because I'm changing the state of the order based
  # on a GET request but that seems to be how PayPal rolls.
  def cancel_paypal
    @order.cancel_paypal!
    flash[:notice] = "PayPal payment cancelled."
    redirect_to order_path(@order)
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

  # Display the invitation form to invite others
  def invite
    # Must be authenticated
    unless current_user
      flash[:notice] = "You'll need a Cafebop account to invite others."
      redirect_to signup_path(:order_id=>@order.id)
      return
    end
    current_user and @order.user ||= current_user
    invited_users = flash[:invited_user_attributes] and @order.invited_user_attributes = invited_users
    # If user's already specified email pre-populate login form
    if !authenticated? && @order.user && @order.user.active
      @user_session = UserSession.new(:email=>@order.user_email)
    end
  end
  
  def send_invitations
    @order.attributes = params[:order]
    if @order.save
      if @order.close_timer_started?
        redirect_to order_path(@order)
      else
        redirect_to invite_order_path(@order)
      end
    else
      flash[:error] = "Unable to save changes"
      redirect_to invite_order_path(@order)
    end
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
    # @order.save
    redirect_to @order
  end

  def destroy
    @order.destroy
    redirect_to orders_path
  end
    

private

  def create_friendship
    if params[:commit] == "Add"
      # Record invited user attributes for invite action to use
      if current_user and fp = params[:friendship]
        if current_user.friendships.create(fp)  
          #Make sure the new friend is selected to be invited
          @order.attributes = params[:order]
          @order.invited_user_attributes << fp[:friend_email]
          @order.start_close_timer = false
          @order.save
        end
      end
      flash[:invited_user_attributes] = @order.invited_user_attributes
      redirect_to invite_order_path(@order)
    end
  end
  
  def unless_invitation_closed
    if @order.invite_closed?
      render :action=>:closed if @order.invite_closed?
    end
  end        
  
  def only_if_pending
    no_cache
    redirect_to order_path(@order) unless @order.pending?
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
    if !current_user and @order.user
      redirect_to login_path(:order_id=>@order.id)
      return
    end
    unless @order.mine?(current_user, session[:order_token])
      flash[:error] = "Whoa! That's not yours."
      redirect_to new_shop_order_path(@order.shop)
    end
  end
  
  
  def mark_as_mine
    session[:order_token] = @order.perishable_token
  end
  
  def only_if_shop_monitoring_queues
    if @shop.accepts_queued_orders? and !@shop.is_monitoring_queues?
      flash[:notice] = "#{@shop} doesn't seem to be monitoring its queues at present. " +
      "If they should be open according to their opening hours, you may like to call them on #{@shop.phone}."
      redirect_to @order
    end
  end

  def check_paypal_status
    # in the unlikely case that the paypal request is still being processed,
    # the order status will still be updated either when the user refreshes
    # the page or when the IPN notification comes in
    if @order.pending_paypal_auth? and @order.paypal_paykey
      paypal_response = gateway.details_for_payment({:paykey=>@order.paypal_paykey})
      case paypal_response.status
      when 'COMPLETED': @order.pay_and_queue!
      when 'EXPIRED':   @order.cancel_paypal!
      end
    end
  end

  def check_delivery_details
    @order.name_required = true
    if @order.valid?
      redirect_to order_path(@order)
    else
      wrangle_order_errors
      redirect_to edit_order_path(@order)
    end
  end
  
  def wrangle_order_errors
    flash[:error] = @order.errors.full_messages.collect{|m| m}.join('. ')
    logger.error @order.errors.full_messages.collect{|m| m}.join('. ')
  end

end

 
class UsersController < ApplicationController

  before_filter :require_login, :except=>[:new, :create, :activate, :activate_invited]
  before_filter :require_admin_rights, :except=>[:new, :create, :activate, :activate_invited]
  # before_filter :require_valid_captcha, :only=>[:create]
  before_filter :require_user_parameters, :only => [:create]
  before_filter :fetch_order, :only =>  [:new, :create]
  
  make_resourceful do
    actions :update, :show, :destroy
  end  
                                  
  def index
    @page = params[:page]
    @users = User.all.paginate(:per_page=>20, :page=>@page)
  end

  def edit
    @user = User.find(params[:id])
  end

  def new
  end
  
  def create                     
    email = params[:user][:email]
    @user = User.find_by_email(email)
    if @user and @user.signed_up?
      flash[:notice] = "You already seem to have an account. Try logging in."
      flash[:email] = email
      redirect_to login_path
      return
    end
    @user ||= User.new(params[:user])
    @user.make_admin if User.count == 0
    if @user.save
      # If we were in the middle of an order when the account was created,
      # associate it with the account so that user can continue after confirm.
      @user.add_favourite(@shop.id) if @shop
      if @order and @order.mine?(nil, session[:order_token])
        @order.user = @user
        @order.save
      end     
      redirect_to root_path # TODO Send the user to a message screen that makes it clearer
      flash[:notice] = "Thanks for signing up! Check your email to permanently activate your account."
    else
      render :action => 'new'
    end
  end
  
  def activate
    @user = User.find_by_perishable_token(params[:token])
    if @user and @user.activate!
      @user.reset_perishable_token!
      UserSession.create(@user)
      flash[:notice] = "Your Cafebop account is now active! Welcome aboard."
      redirect_to root_path
    else
      flash[:notice] = 'Your account may already be active. Try logging in.'
      redirect_to login_path
    end
  end 
    
  # Active a user that's accepted an order invitation and has now
  # entered a password and password confirmation.
  def activate_invited
    # users who have logged in aren't asked to activate their account again
    # so we'll pretend    
    if params[:user] and user = current_user
      user.sign_up
      user.attributes = params[:user]

      if user.remember_me
        current_user_session.remember_me = true 
        user_session = current_user_session
        user_session.send :save_cookie
      end
      user.save and flash[:notice] = "Welcome aboard, #{user}."
      Notifications.deliver_welcome user
    end
    if order_id = params[:order_id]
      redirect_to order_path(order_id)
    else
      redirect_to root_path
    end
  end
  
  def activation_sent
    @user = User.find(params[:id])
  end 
  
  private
  
  def current_objects
    @current_objects ||= User.find(:all)
  end   
  
  def current_object
    @current_object ||= User.find(params[:id])
  end
  
  def require_user_parameters
    redirect_to signup_path unless params[:user]
  end
end
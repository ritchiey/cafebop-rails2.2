UserObserver.instance

class UsersController < ApplicationController

  before_filter :require_login, :except=>[:new, :create, :activate]
  before_filter :require_admin_rights, :except=>[:new, :create, :activate]   

  make_resourceful do
    actions :index, :update, :show, :destroy
  end  
                                  
  before_filter :require_valid_captcha, :only=>[:create]

  def edit
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.add_role('cafebop_admin') if User.count == 0
    if @user.save
      redirect_to root_path
      flash[:notice] = "Thanks for signing up! Check your email to permanently activate your account. "
    else
      render :action => 'new'
    end
  end
  
  def activate
    if @user = User.find_by_perishable_token(params[:token]) and @user.activate!
      @user.reset_perishable_token!
      UserSession.create(@user)
      flash[:notice] = "Your account has been activated"
      redirect_to root_path
    else
      flash[:error] = 'Sorry, could not activate account'
      redirect_to new_user_path
    end
  end  
  
  private
  
  def current_objects
    @current_objects ||= User.find(:all)
  end   
  
  def current_object
    @current_object ||= User.find(params[:id])
  end
end
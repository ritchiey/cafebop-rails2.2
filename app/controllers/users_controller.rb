UserObserver.instance

class UsersController < ApplicationController
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
    if @user = User.find_by_perishable_token(params[:token])
      @user.reset_perishable_token!
      UserSession.create(@user)
      flash[:notice] = "Your account has been activated"
      redirect_to root_path
    else
      flash[:error] = 'Sorry, could not activate account'
      redirect_to new_user_path
    end
  end
end
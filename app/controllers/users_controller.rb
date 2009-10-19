UserObserver.instance

class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_path
      flash[:notice] = "Thanks for signing up"
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
  
  def edit
    @user = current_user
    @user.valid?
  end
  
  # This action has the special purpose of receiving an update of the RPX identity information
  # for current user - to add RPX authentication to an existing non-RPX account.
  # RPX only supports :post, so this cannot simply go to update method (:put)
  def addrpxauth
          @user = current_user
          if @user.save
                  flash[:notice] = "Successfully added RPX authentication for this account."
                  render :action => 'show'
          else
                  render :action => 'edit'
          end
  end
  
end
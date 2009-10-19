class UserSessionsController < ApplicationController
  
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if @user_session.new_registration?
        flash[:notice] = "Welcome to Cafebop"
        redirect_to root_path
      else
        if @user_session.registration_complete?
          flash[:notice] = "Successfully signed in."
          redirect_to root_path
        else
          redirect_to root_path
        end
      end
    else
      flash[:error] = "Failed to login or register."
      redirect_to new_user_session_path
    end
  end



  def destroy
    current_user_session.destroy
    redirect_to root_path
  end  
  
  def index
    redirect_to root_url
  end
  
  
end
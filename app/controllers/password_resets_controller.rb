# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController

  before_filter :load_user_using_perishable_token, :only => [:edit, :update]

  def new
    @password_reset = PasswordReset.new
    render
  end

  def create
    @password_reset = PasswordReset.new(params[:password_reset])
    if @password_reset.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you. " +
      "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "No user was found with that email address"
      render :action => :new
    end
  end    
  
  
  def edit  
    render  
  end

  def update  
    @password_reset.attributes = params[:password_reset]
    if @password_reset.save  
      flash[:notice] = "Password successfully updated"
      redirect_to root_path
    else  
      render :action => :edit  
    end  
  end  

  private  

  def load_user_using_perishable_token  
    @password_reset = PasswordReset.find_using_perishable_token(params[:id])
    unless @password_reset
      flash[:notice] = "We're sorry, but we could not locate your account. " +  
      "If you are having issues try copying and pasting the URL " +  
      "from your email into your browser or restarting the " +  
      "reset password process."  
      redirect_to root_url  
    end  
  end

end

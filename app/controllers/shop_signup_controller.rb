class ShopSignupController < ApplicationController
  
  before_filter :find_instance, :except => [:new, :create]
  
  def new
    @new_shop = Shop.new
  end
  
  def create
    @new_shop = Shop.new(params[:shop])
    if @new_shop.save
      redirect_to activation_form_shop_signup_path(@new_shop)
    else
      redirect_to :action=>:new
    end
  end
  
  def activation_form
  end
  
  def choose_password_for
  end


  def set_password_for
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
    
    redirect_to :action=>:active
  end
    
  def update
    changes = params[:shop].reject {|k,v| k.to_sym != :activation_confirmation}
    if !@new_shop.active? and @new_shop.update_attributes(changes)
      user = @new_shop.owner
      login_as(user)
      if user.signed_up?
        redirect_to :action=>:active
      else
        redirect_to choose_password_for_shop_signup_path(@new_shop)
      end
    else
      render :action=>:activation_form
    end
  end  
  
  def active
  end

private            

  def find_instance
    @new_shop = find_shop(params[:id])
  end
  
end

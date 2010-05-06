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
    
  def update
    changes = params[:shop].reject {|k,v| k.to_sym != :activation_confirmation}
    if !@new_shop.active? and @new_shop.update_attributes(changes)
      login_as(@new_shop.owner)
      redirect_to :action=>:active
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

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
      redirect_to :new
    end
  end
  
  def activation_form
  end
    
  def update
    changes = params[:shop]
    if @new_shop.update_attributes(changes)
      redirect_to :active
    end
  end  
  
  def active
  end

private            

  def find_instance
    @new_shop = Shop.find(params[:id])
  end
  
end

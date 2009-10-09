class ShopsController < ApplicationController    
  
  def new
    @shop = Shop.new
    @shop.menus.build
  end               
  
  def show
    @shop = Shop.find(params[:id])
    redirect_to new_shop_order_path(@shop)
  end
  
  def create
    @shop = Shop.new(params[:shop])
    if @shop.save
      redirect_to root_path
    else                   
      render :action=>'new'
    end
  end

  def index
    @shops = Shop.find :all
  end               
  
  def edit
    @shop = Shop.find(params[:id])
  end
    
end

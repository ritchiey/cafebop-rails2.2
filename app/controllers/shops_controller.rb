class ShopsController < ApplicationController    
  
  def new
    @shop = Shop.new
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

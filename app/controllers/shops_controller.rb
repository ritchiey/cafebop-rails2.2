class ShopsController < ApplicationController    
  
  def index
    @shops = Shop.find :all
  end               
  
  def edit
    @shop = Shop.find(params[:id])
  end
    
end

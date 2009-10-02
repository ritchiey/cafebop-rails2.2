class ShopsController < ApplicationController    
  
  def index
    @shops = Shop.find :all
  end
    
end

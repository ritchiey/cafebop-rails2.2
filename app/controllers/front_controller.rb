class FrontController < ApplicationController
  
  geocode_ip_address
  
  
  def index             
    @location = session[:geo_location]
    @search = Search.new(@location || {})
    @shops = @search.shops   
  end
  
  
end

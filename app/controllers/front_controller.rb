class FrontController < ApplicationController
  
  #geocode_ip_address
  
  
  def index             
    #@location = session[:geo_location]
    @search = Search.new
    #@shops = @search.shops   
  end
  
  def cookies_test
    super
  end
  
end

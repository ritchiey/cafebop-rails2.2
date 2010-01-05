class FrontController < ApplicationController
  
  #geocode_ip_address
  
  
  def index
    flash[:notice] = "Test flash message."
    flash[:error] = "Something went wrong!!"
    @search = Search.new           
    if current_user
      @current_orders = current_user.orders.current.recent.newest_first.all
    end
  end
  
  def cookies_test
    super
  end
  
end

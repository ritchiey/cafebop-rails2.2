class FrontController < ApplicationController
  
  #geocode_ip_address
  
  
  def index
    @search = Search.new           
    if current_user
      @current_orders = current_user.orders.current.recent.newest_first.all
      @work_contracts = current_user.work_contracts
    end
  end
  
  def cookies_test
    super
  end
  
end

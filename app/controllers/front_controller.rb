class FrontController < ApplicationController
  
  #geocode_ip_address
  
  before_filter :current_user_collections, :only=>[:index]
  
  def index
    @search = Search.new
    respond_to do |format|
      format.html        
      format.iphone
      format.json do
        render :json=>{:current_orders=>@current_orders,
                       :work_contracts=>@work_contracts,
                       :friendships=>@friendships}
      end              
    end                 
  end
  
  def cookies_test
    super
  end
  
end

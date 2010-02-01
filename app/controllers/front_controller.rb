class FrontController < ApplicationController
  
  #geocode_ip_address
  
  before_filter :current_user_collections, :only=>[:index]
  
  def index
    @search = Search.new           
  end
  
  def cookies_test
    super
  end
  
end

class FrontController < ApplicationController
  
  #geocode_ip_address
  
  before_filter :current_user_collections, :only=>[:index]
  
  def index
    @search = Search.new
    respond_to do |format|
      format.html        
      format.mobile
      format.json do                                                        
        work_contracts_json = @work_contracts.to_json({:only=>[:role], :include=>{:shop=>{:only=>[:name, :id]}}})
        json = "{work_contracts: #{work_contracts_json}}"
        render :json=>json
      end              
    end                 
  end
  
  
  # Disable cookie test for front page
  def cookies_test
    super
  end
  
end

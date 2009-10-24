class FrontController < ApplicationController
  
  def index  
    @search = Search.new
  end
  
  
end

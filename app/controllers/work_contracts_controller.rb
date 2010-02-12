class WorkContractsController < ApplicationController

  before_filter :require_login
  
  make_resourceful do
    actions :index
  end 
  
end

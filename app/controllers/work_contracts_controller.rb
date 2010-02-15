class WorkContractsController < ApplicationController

  before_filter :require_login
  before_filter :only_if_mine
  
  make_resourceful do
    actions :index
    belongs_to :user
  end
  
  def index
  end
  
  private
  
  def only_if_mine
    unauthorized unless current_user and current_user.id == params[:user_id].to_i
  end
end

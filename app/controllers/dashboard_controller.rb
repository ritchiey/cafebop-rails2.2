class DashboardController < ApplicationController

  before_filter :require_login
  before_filter :require_admin_rights
  
  def show
    @stat = Stat.new
  end       
  
end

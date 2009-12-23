class PaymentNotificationsController < ApplicationController   
  
  protect_from_forgery :except=>[:create]
  before_filter :cookies_required, :except => [:create]

  #TODO: only admin should have access to everything except create
  
  def create  
    PaymentNotification.create!(:params => params, :order_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id] )  
    render :nothing => true  
  end
end    
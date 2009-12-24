require 'net/http'
require 'net/https'

class PaymentNotificationsController < ApplicationController   
  
  include Paypal
  
  protect_from_forgery :except=>[:create]
  before_filter :cookies_required, :except => [:create]
  before_filter :verify_with_paypal, :only => [:create]

  #TODO: only admin should have access to everything except create
  
  def create  
    PaymentNotification.create!(:params => params, :order_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id] )  
    render :nothing => true  
  end

  # Connect to paypal and send them the params just received
  def verify_with_paypal                           
    paypal_verify_url = paypal_ipn_verify_url
    logger.info "XXXXXXXXXX Checking: #{paypal_verify_url}"
    response = paypal_service.request_post(paypal_verify_url, request.raw_post) 
    logger.info response       
    render(:nothing=>true) unless response.body == 'Confirmed'
  end

end    
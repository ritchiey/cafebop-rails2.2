require 'net/http'
require 'net/https'

class PaymentNotificationsController < ApplicationController   
  
  include ActiveMerchant::Billing::Integrations
  
  protect_from_forgery :except=>[:create]
  before_filter :cookies_required, :except => [:create]

  
  def create                               
    form_data = request.env['rack.request.form_vars']
    notify = Paypal::Notification.new(form_data)
    order = Order.find(params[:order_id]) #TODO: This may be insecure because someone could specify a different order_id
    if notify.acknowledge
      begin
        if notify.complete? # TODO and order.total == notify_amount
          order.pay_and_queue!
          PaymentNotification.create!(:params => params, :order_id => params[:invoice], 
          :status => params[:payment_status], :transaction_id => params[:txn_id])
        else
          logger.debug_variables(binding)
        end        
      rescue Exception => e
        log_error e
      end
    end
    
    render :nothing => true  
  end

end    
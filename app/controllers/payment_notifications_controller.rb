require 'net/http'
require 'net/https'

class PaymentNotificationsController < ApplicationController   
  
  include ActiveMerchant::Billing::Integrations
  
  protect_from_forgery :except=>[:create]
  before_filter :cookies_required, :except => [:create]

  
  def create                               
    form_data = request.env['rack.request.form_vars']
    notify = Paypal::Notification.new(form_data)
    shop_transaction =  params['transaction']['0']
    order = Order.find(shop_transaction['.invoiceId'])
    if notify.acknowledge
      begin
        if notify.complete? and order # TODO and order.total == notify_amount
          order.pay_and_queue!
          PaymentNotification.create!(:params => params, :order_id => order.id, 
          :status => params[:payment_status], :transaction_id => shop_transaction[".id"])
        end        
      rescue Exception => e
        log_error e
      end
    end
    
    render :nothing => true  
  end

end    
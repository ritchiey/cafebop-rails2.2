require 'net/http'
require 'net/https'
require 'uri'

module PaypalEnabled
  
  class PaypalResponse
    def initialize(json_data)
      @data = ActiveSupport::JSON.decode(json_data)
    end
    
    def succeeded?
      @succeeded ||= @data['responseEnvelope']['ack'].downcase != 'failure' 
    end
               
    def pay_key
      @data['payKey']
    end
    
    def [](key)
      @data[key]
    end
  end
    
  def request_paypal_authorization!
    if pending?
      http_response = http.request_post(paypal_url('Pay'), payment_json, http_headers)
      PaypalResponse.new(http_response.body).tap do |response|
        if response.succeeded?
          self.state = 'pending_paypal_auth'
          save!
        end
      end
    end
  end


protected

  def http
    @http ||= Net::HTTP.new(paypal_hostname, paypal_port).tap do |http|
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  def payment_json
    {
      :returnUrl => return_url,
      :currencyCode => 'USD',
      :receiverList => {
        :receiver => [
            {:email=>'paypal_1261211817_biz@cafebop.com', :amount=>'10.00'}
          ]
      },
      :requestEnvelope => {
        :errorLanguage => 'en_US',
      },
      :cancelUrl => cancel_url,
      :actionType => 'PAY'
    }.to_json
  end    
  
  def return_url
    'http://localhost:3000/paypal_success'
  end
  
  def cancel_url
    'http://localhost:3000/paypal_cancelled'
  end

  def http_headers
    {
      'X-PAYPAL-SECURITY-USERID' => api_username,
      'X-PAYPAL-SECURITY-PASSWORD' => api_password,  
      'X-PAYPAL-SECURITY-SIGNATURE' => signature,
#      "X-PAYPAL-SECURITY-SUBJECT" => ???,
      'X-PAYPAL-REQUEST-DATA-FORMAT' => 'JSON',
      'X-PAYPAL-RESPONSE-DATA-FORMAT' => 'JSON',
      'X-PAYPAL-APPLICATION-ID' => application_id,
#      'X-PAYPAL-DEVICE-IPADDRESS' => 
    }
  end

  def paypal_url(command)
    "https://#{paypal_hostname}:#{paypal_port}/AdaptivePayments/#{command}"
  end
  
  def paypal_hostname
    "svcs.sandbox.paypal.com"
  end
  
  def paypal_port
    '443'
  end    
  
  def api_username
    'paypal_1261211817_biz_api1.cafebop.com'
  end    
  
  def api_password
    '1261211823'
  end

  def signature
    'ADh04iX7rBFjHo95xYz0duNBBfQ3AkZYxa4p-E6cfOK9rOgGxcebjHuU'
  end                                            
  
  def application_id
    'APP-80W284485P519543T'
  end
  
end
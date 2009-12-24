require 'net/http'
require 'net/https'
require 'uri'

module PaypalEnabled    
  
  include Paypal
  
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
    
  def request_paypal_authorization!(arguments={})
    if pending?
      http_response = paypal_service.request_post(paypal_url('Pay'), payment_json(arguments), http_headers)
      @response = PaypalResponse.new(http_response.body).tap do |response|
        if response.succeeded?
          self.state = 'pending_paypal_auth'
          save!
        end
      end
    end
  end 
  
  # The URL that the user should be redirected to
  def paypal_auth_url(response)
    response ||= @response
    "https://www.#{paypal_base_hostname}/webscr?cmd=_ap-payment&paykey=#{response.pay_key}"
  end

protected

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


end
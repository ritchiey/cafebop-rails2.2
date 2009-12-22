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
      @response = PaypalResponse.new(http_response.body).tap do |response|
        if response.succeeded?
          self.state = 'pending_paypal_auth'
          save!
        end
      end
    end
  end 
  
  # The URL that the user should be redirected to
  def paypal_auth_url return_url
    "https://www.#{paypal_base_hostname}/webscr?cmd=_ap-payment&paykey=#{@response.pay_key}"
  end


protected

  def http
    @http ||= Net::HTTP.new(paypal_services_hostname, paypal_port).tap do |http|
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
            {:email=>'us_1261469612_biz@cafebop.com', :amount=>'1.00', :primary=>'true'},
            {:email=>'paypal_1261211817_biz@cafebop.com', :amount=>'1.00', :primary=>'false'},
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
    "https://#{paypal_services_hostname}:#{paypal_port}/AdaptivePayments/#{command}"
  end
  
  def paypal_services_hostname
    "svcs.#{paypal_base_hostname}"
  end
  
  def paypal_base_hostname
    "sandbox.paypal.com"
  end
  
  def paypal_port
    '443'
  end    
  
  def api_username
    'us_1261469612_biz_api1.cafebop.com'
  end    
  
  def api_password
    '1261469614'
  end

  def signature
    'A4ST5PBqjKmYFbqmR24zb37caokmALi8VgzXjcetjlgH7hvloAlXecuB'
  end                                            
  
  def application_id
    'APP-80W284485P519543T'
  end
  
end
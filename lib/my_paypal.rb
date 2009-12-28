module MyPaypal
  
  protected

    def paypal_service
      @http ||= Net::HTTP.new(paypal_services_hostname, paypal_port).tap do |http|
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def payment_json(arguments={})
      {
        :actionType => 'PAY',
        :ipnNotificationUrl => default_ipn_url,
        :returnUrl => default_return_url,
        :cancelUrl => default_cancel_url,
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
      }.merge(arguments).to_json
    end    

    def default_return_url
      'http://localhost:3000/paypal_success'
    end

    def default_cancel_url
      'http://localhost:3000/paypal_cancelled'
    end                        

    def default_ipn_url
      'http://209.40.206.88:5555/payment_notifications'
    end
    
    # URL to connect to to verify that received IPN was ok
    def paypal_ipn_verify_url
      "https://www.#{paypal_base_hostname}:#{paypal_port}/cgi-bin/webscr?cmd=_notify-validate"
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
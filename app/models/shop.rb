class Shop < ActiveRecord::Base
  
  fields do
    name    :string
    phone   :string
    fax     :string
    website :string    
    state   :string, :default=>'community'
    email_address :email_address
    timestamps
  end              
  
  
  has_many :orders
  has_many :menus
  has_many :operating_times
        
  def queues_in_shop_payments?
    express?
  end

  def accepts_in_shop_payments?
    return true if community?
    # TODO: Give express and pro shops the chance to
    # refuse in-shop payments if Paypal is configured
    true
  end   
  
  def accepts_paypal_payments?
    return false if community? or express?
    false
    # TODO: Allow pro shops to enable this
  end
  
  # State related    
  def community?() state == 'community'; end
  def express?() state == 'express'; end
  def professional?() state == 'professional'; end
  
  def go_community!
    self.state = 'community'
  end
  
  def go_express!
    self.state = 'express'
  end

  def go_professional!
    self.state = 'professional'
  end
  # End state related

end

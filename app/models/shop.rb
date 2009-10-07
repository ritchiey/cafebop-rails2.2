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
  
  def to_s() name; end          
  
  
  has_many :orders, :dependent=>:destroy
  has_many :menus, :dependent=>:destroy
  has_many :operating_times, :dependent=>:destroy
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts
  has_many :staff, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'staff'"]
  
        
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

  def claim!(user)
    if community?
      wc = work_contracts.find(:first, :conditions=>{:user_id=>user.id})
      wc ||= shop.work_contracts.build(:user=>user, :role=>'manager')
      wc.role = 'manager'
      wc.save!
      go_express!
      #TODO Send claimed email
    end
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

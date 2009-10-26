class Shop < ActiveRecord::Base
  
  fields do
    name    :string
    phone   :string
    fax     :string
    website :string
    state   :string, :default=>'community'
    email_address :email_address
    street_address  :string
    postal_address  :string
    lat     :float
    lng     :float
    timestamps   
  end    
                        
  attr_accessible :name, :phone, :fax, :email_address, :website, :street_address, :postal_address, :lat, :lng, :cuisine_ids

  def cuisine_ids=(ids)
    ids.each {|id| shop_cuisines.build(:cuisine_id=>id)}
  end 
    
  def to_s() name; end          
  
  has_many :orders, :dependent=>:destroy
  has_many :item_queues, :dependent=>:destroy
  has_many :menus, :dependent=>:destroy
  has_many :menu_items, :through => :menus
  has_many :operating_times, :dependent=>:destroy
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts
  has_many :staff, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'staff'"]
  has_many :managers, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'manager'"]
  has_many :service_areas
  has_many :serviced_suburbs, :through=>:service_areas, :source=>:suburb
  has_many :shop_cuisines
  has_many :cuisines, :through=>:shop_cuisines
  
  accepts_nested_attributes_for :menus 
  acts_as_mappable


  named_scope :by_name_suburb_or_postcode, lambda  {|term|
    {
      :include=>[:serviced_suburbs],
      :conditions=>["suburbs.postcode = ? or LOWER(shops.name) like ? or LOWER(suburbs.name) like ?", term, "#{term}%".downcase, "#{term}%".downcase],
    }
  }


  def address
    street ? "#{street} " : "" +
    suburb ? "#{suburb} " : "" +
    province ? "#{province} " : "" +
    country ? "#{country} " : "" +
    postcode ? "#{postcode} " : ""
  end
  
  def is_manager?(user)
    managers.include?(user)
  end
  
  def can_be_claimed_by?(user)
    self.community? && user && !user.claims.any? {|claim| claim.shop == self}
  end

  def can_have_queues?
    !self.community?
  end
        
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
      wc ||= work_contracts.build(:user=>user, :role=>'manager')
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
    self.save
  end
  
  def go_express!
    queue = item_queues.create({:name=>'Default'})
    menu_items.each do |item|
      item.item_queue = queue
      item.save
    end
    self.state = 'express'
    self.save
  end

  def go_professional!
    self.state = 'professional'
    self.save
  end
  # End state related
                

  # Permissions
  def can_edit?(acting_user)                 
    return false unless acting_user
    return true if (acting_user.manages? self)
   false
  end     
  
   
  def has_item_queues?
    !item_queues.empty?
  end
  
  def add_generic_cafe_menus
    menus.create(:name=>'Drinks',
                 :menu_items_attributes=>[
                     {:name=>'Coffee',
                      :flavours_attributes=>[
                        {
                          :name=>'Flat White',
                          :description=>'Frothy Perfection'
                        },
                        {
                          :name=>'Cappucino',
                          :description=>'Frothy Perfection plus chocolate sprinkles'
                        }
                        ], # flavours_attributes
                      :sizes_attributes=>[
                          { :name=>'Regular', :price=>'3.80' },
                          { :name=>'Large', :price=>'4.50' }
                        ]
                      }
                   ] #menu_item_attributes
                   )
  end
  
end

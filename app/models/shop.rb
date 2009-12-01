class Shop < ActiveRecord::Base
  
  fields do
    name    :string
    shortname :string
    phone   :string
    fax     :string
    website :string
    state   :string, :default=>'community'
    email_address :email_address
    accept_queued_orders :boolean, :default=>false
    street_address  :string
    postal_address  :string
    lat     :float
    lng     :float
    generic_orders :boolean, :default=>true
    header_background_updated_at :datetime
    header_background_file_name :string
    header_background_content_type :string
    header_background_file_size :integer
    timestamps   
  end    

  before_validation_on_create :set_shortname
                        
  attr_accessible :name, :shortname, :phone, :fax, :email_address, :website, :street_address, :postal_address, :lat, :lng, :cuisine_ids,
        :header_background, :franchise_id

  validates_presence_of :name, :shortname, :phone, :street_address

  def cuisine_ids=(ids)
    ids.each {|id| shop_cuisines.build(:cuisine_id=>id)}
  end 
    
  def to_s() name; end          
  
  has_many :orders, :dependent=>:destroy
  has_many :item_queues, :dependent=>:destroy, :order=>:position 
  has_many :menus, :dependent=>:destroy, :order=>:position 
  has_many :menu_items, :through => :menus
  has_many :operating_times, :dependent=>:destroy, :order=>:position 
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts
  has_many :staff, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'staff'"]
  has_many :managers, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'manager'"]
  has_many :service_areas
  has_many :serviced_suburbs, :through=>:service_areas, :source=>:suburb
  has_many :shop_cuisines
  has_many :cuisines, :through=>:shop_cuisines, :conditions=>{:franchise=>false}
  belongs_to :franchise, :class_name => "Cuisine", :foreign_key => "franchise_id", :conditions=>{:franchise=>true}
  accepts_nested_attributes_for :menus 
  acts_as_mappable
  
  has_attached_file :header_background,
      paperclip_options('shops').merge(:styles=>{:header=>"950x180>"})
      

  named_scope :by_name_suburb_or_postcode, lambda  {|term|
    {
      :include=>[:serviced_suburbs],
      :conditions=>["suburbs.postcode = ? or LOWER(shops.name) like ? or LOWER(suburbs.name) like ?", term, "#{term}%".downcase, "#{term}%".downcase],
    }
  }      
  
  named_scope :with_cuisine, lambda {|id| 
    {
      :include=>[:shop_cuisines],
      :conditions=>["shop_cuisines.cuisine_id = ?", id]
    }
    } 
    
  named_scope :community, :conditions=>{:state=>'community'}
  named_scope :express, :conditions=>{:state=>'express'}
  named_scope :professional, :conditions=>{:state=>'professional'}

  def virtual_menus
    franchise ? Menu.for_franchise(franchise).with_items : Menu.virtual_for_shop(self).with_items
  end
  
  # Return the menus that the customer should see when ordering whether
  # the be generic or specific to this shop
  def effective_menus
    community? ? virtual_menus : menus 
  end

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

  def accepts_queued_orders?
    can_have_queues? and accept_queued_orders
  end

  def start_accepting_queued_orders!
    if can_have_queues?
      self.accept_queued_orders = true
      save!
    end
  end
        
  def stop_accepting_queued_orders!
    self.accept_queued_orders = false
    save!
  end
        
  def queues_in_shop_payments?
    accepts_queued_orders? and accepts_in_shop_payments?
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
  
# def go_community!
#   self.state = 'community'
#   self.save
# end
  
  # Switch the shop to express state. Express means that the
  # shop can receive orders to a queue but their customers can't
  # pay online.
  # When switching from community mode (only done once) the generic
  # menus are copied so that the shop can use them as a starting point
  # to produce custom menus.
  # A default queue is created for the shop and all menu_items are assigned
  # to it.
  def go_express!
    if community?
      self.menus = virtual_menus.map {|menu| menu.deep_clone }
      queue = item_queues.create({:name=>'Default'})
      menu_items.each do |item|
        item.item_queue = queue
        item.save
      end
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
    return true if acting_user.is_admin?
    return true if (acting_user.manages? self)
   false
  end     
  
   
  def has_item_queues?
    !item_queues.empty?
  end
  
  private
  
  def set_shortname
    if self[:name]
      self[:shortname] ||= self[:name].gsub(/[ _]/, '-').gsub(Regexp.new('[!@#$%^&\*()\']'), "")
    end
  end
  
end

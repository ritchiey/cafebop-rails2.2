class Shop < ActiveRecord::Base
  
  fields do
    name    :string
    permalink :string
    phone   :string
    fax     :string
    website :string
    state   :string, :default=>'community'
    email_address :email_address
    accept_queued_orders :boolean, :default=>false 
    accept_paypal_orders :boolean, :default=>false
    paypal_recipient  :string    
    fee_threshold_in_cents :integer, :default=>0
    street_address  :string
    postal_address  :string
    refund_policy   :text
    motto           :text
    lat     :float
    lng     :float
    location_accuracy :integer # Google's GGeoAddressAccuracy
    generic_orders :boolean, :default=>true
    header_background_updated_at :datetime
    header_background_file_name :string
    header_background_content_type :string
    header_background_file_size :integer
    timestamps   
  end    
  
  def self.find_by_id_or_permalink(term, options=nil)
    term = term.to_s
    (term =~ /^[0-9]/o) ?  find(term, options) : find_by_permalink(term, options)
  end

  treat_as_currency :fee_threshold

  # permalinks are now optionally set as/after stores are claimed.
  # before_validation_on_create :set_permalink
                        
  attr_accessible :name, :permalink, :phone, :fax, :email_address, :website, :street_address, :postal_address, :lat, :lng, :cuisine_ids,
        :header_background, :franchise_id, :refund_policy
   
  # attr_accessible :fee_threshold  # disabled because it doesn't comply with PayPal conditions

  #validates_presence_of :name, :permalink, :street_address
  validates_format_of :permalink, :with => /^[A-Za-z0-9-]+$/, :message => 'The permalink can only contain alphanumeric characters and dashes.', :allow_blank => true
  validates_exclusion_of :permalink, :in => %w( support blog www billing help api ), :message => "The permalink <strong>{{value}}</strong> is reserved and unavailable."
  # validates_uniqueness_of :permalink, :on => :create, :message => "already exists"

  after_create :guess_cuisines

  def cuisine_ids=(ids)
    ids.each {|id| shop_cuisines.build(:cuisine_id=>id)}
  end 
  
  def ever_charges_processing_fee?
    fee_threshold_in_cents > 0
  end
  
  def processing_fee
    0.30
  end
                 
  def to_param()
     permalink || "#{id}-#{calc_permalink}"
  end
  
  def to_s() name; end          

  def validate
    errors.add('street_address', 'Must be able to be located on map.') unless (lat and lng)
  end
  
  has_many :orders, :dependent=>:destroy, :order=>'created_at DESC'
  has_many :item_queues, :dependent=>:destroy, :order=>:position 
  has_many :customer_queues, :dependent=>:destroy, :order=>:position 
  has_many :menus, :dependent=>:destroy, :order=>:position 
  has_many :menu_items, :through => :menus
  has_many :operating_times, :dependent=>:destroy, :order=>:position 
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts, :dependent=>:destroy
  has_many :patrons, :through => :work_contracts, :source =>:user, :conditions=>["work_contracts.role = 'patron'"]
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
  
  def commission_rate
    0.01
  end
  
  def is_manager?(user)
    managers.include?(user)
  end
  
  def is_staff?(user)
    staff.include?(user) || is_manager?(user)
  end
  
  def can_be_claimed?
    self.community?
  end
  
  def can_be_claimed_by?(user)
    can_be_claimed? && user && !user.claims.any? {|claim| claim.shop == self}
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
      RAILS_DEFAULT_LOGGER.info "Queuing enabled for shop #{id}"
      Notifications.send_later(:deliver_queuing_enabled, self)
    end
  end
        
  def stop_accepting_queued_orders!
    disable_paypal_payments! if accepts_paypal_payments?
    self.accept_queued_orders = false
    save!
    RAILS_DEFAULT_LOGGER.info "Queuing disabled for shop #{id}"
    Notifications.send_later(:deliver_queuing_disabled, self)
  end
                    
  def can_enable_paypal_payments?
    !community? and accepts_queued_orders?
  end

  def enable_paypal_payments!
    if can_enable_paypal_payments?
      self.accept_paypal_orders = true
      save!
      RAILS_DEFAULT_LOGGER.info "PayPal enabled for shop #{id}"
      Notifications.send_later(:deliver_paypal_enabled, self)
    end
  end
        
  def disable_paypal_payments!
    self.accept_paypal_orders = false
    save!
    RAILS_DEFAULT_LOGGER.info "PayPal disabled for shop #{id}"
    Notifications.send_later(:deliver_paypal_disabled, self)
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
    return false if community?
    accept_paypal_orders
  end

  def claim!(user)
    if community?             
      wc = work_contracts.find(:first, :conditions=>{:user_id=>user.id})
      wc ||= work_contracts.build(:user=>user, :role=>'manager')
      wc.role = 'manager'
      wc.save!
      self.paypal_recipient = user.email
      go_express!
      #TODO Send claimed email
    end
  end
  
  # State related    
  def community?() state == 'community'; end
  def express?() state == 'express'; end
  def professional?() state == 'professional'; end

  def transition_to desired_state
    states = %w/community express professional/
    raise "Invalid state for shop" unless states.include?(desired_state)
    current_index = states.index(self.state)
    desired_index = states.index(desired_state)
    if current_index < desired_index
      (current_index+1).upto(desired_index) {|i| self.send "go_#{states[i]}!" }
    elsif current_index > desired_index
      (current_index-1).downto(desired_index) {|i| self.send "go_#{states[i]}!" }
    end
  end
  
  
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
      customer_queues.create
      item_queues.create({:name=>'Default'}).tap do |queue|
        menu_items.each do |item|
          item.item_queue = queue
          item.save
        end
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
  
  def can_view_history?(acting_user)
    return false unless acting_user
    return true if acting_user.is_admin?
    return true if (acting_user.manages? self)
    false
  end
   
  def has_item_queues?
    !item_queues.empty?
  end
  
  def is_monitoring_queues?
    if accepts_queued_orders?
      customer_queues.any? {|q| q.active}
    end
  end
  private
  
  def set_permalink
    if self[:name]
      self[:permalink] ||= calc_permalink
    end
  end
  
  def calc_permalink
    self[:name].gsub(/[ _]/, '-').gsub(Regexp.new('[!@#$%^&\*()\']'), "").downcase
  end
  
  def guess_cuisines
    Cuisine.matching_name(name).each {|c| shop_cuisines.create(:cuisine=>c)}
  end    


end

class User < ActiveRecord::Base

  WORST_REPUTATION = -10
  BEST_REPUTATION = 10

  acts_as_authentic
  easy_roles :roles
  include Gravatar
  
  def self.possible_roles
    %w/cafebop_admin/
  end
  
  fields do  
    name                :string
    email               :string 
    phone               :string
    address             :string
    active              :boolean, :default=>false, :null=>false
    crypted_password    :string
    password_salt       :string
    persistence_token   :string   
    perishable_token    :string  
    roles               :string, :default=>"--- []"
    # Disabling because Heroku seems to return the failed_login_count as a string
    # which then crashes the brute force protection in authlogic
    # login_count         :integer, :null=>false, :default=>0
    # failed_login_count  :integer, :null=>false, :default=>0
    last_login_at       :datetime
    last_login_ip       :string
    current_login_at    :datetime
    current_login_ip    :string
    email_offers        :boolean, :default=>true
    dob                 :date
    reputation          :integer, :default=>0
    timestamps
  end                          
  
  before_save :update_dob
  
  # This is a bit ugly. I've just placed this here to let the
  # form processed by activate_invited work.
  attr_accessor :remember_me
  
  attr_accessor :dob_day, :dob_month
  attr_accessor :suppress_activation_email
  
  acts_as_mappable :default_distance=>:miles
         
  has_many :cuisine_choices
  has_many :work_contracts, :dependent=>:destroy
  has_many :shops, :through => :work_contracts
  has_many :friendships, :class_name =>"Friendship", :foreign_key => "user_id"
  has_many :friends, :through=>:friendships, :source=>:friend #, :order=>'email ASC'
  has_many :fanships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :fans, :through=>:fanships, :source=>:user
  has_many :orders
  has_many :owned_shops, :class_name => "Shop", :foreign_key => "owner_id"
  
  named_scope :email_in, lambda {|emails| {:conditions=>{:email=>emails}}}
  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/io, :on => :create
  validates_uniqueness_of :email 
  
  def to_s() name || shortened_email; end 
  
  def add_favourite(shop_id)
    work_contracts.find_or_create_by_shop_id(shop_id)
  end

  def make_admin
    add_role('cafebop_admin')
  end

  def shortened_email    
    e = email
    i = e.index('@')
    e[0,i]
  end
  
  def active?
    active
  end     
  
  def activate!
    self.active = true
    save
  end        
  
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifications.deliver_password_reset_instructions(self)  
  end
  
  def is_admin?() is_cafebop_admin?; end

  
  def manages?(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    shop && work_contracts.any? {|wc| wc.role=='manager' and wc.shop_id == shop}
  end
  
  def is_patron_of?(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    shop && work_contracts.any? {|wc| wc.role=='patron' and wc.shop_id == shop}
  end
  
  def becomes_manager_of(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    wc = work_contracts.find_or_create_by_shop_id(:shop_id=>shop, :role=>'manager')
    unless wc.role == 'manager'
      wc.role = 'manager'
      wc.save
    end
  end
  
  def becomes_patron_of(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    wc = work_contracts.find_or_create_by_shop_id(:shop_id=>shop, :role=>'patron')
  end
  
  def works_at?(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    shop && work_contracts.any? {|wc| wc.shop_id == shop and %w(staff manager).include?(wc.role) }
  end
  

  def can_access_queues_of?(shop)
    shop and shop.can_have_queues? and (works_at?(shop) or is_admin?)  
  end

  def can_manage_queues_of?(shop)
    shop and shop.can_have_queues? and (manages?(shop) or is_admin?)  
  end

  def can_edit_shop?(shop)
    is_admin? or manages?(shop)
  end
  
  def can_delete_shop?(shop)
    is_admin?
  end

  def self.stats
    {
      :total => count
    }
  end

  def self.for_email(email, options={})
    find_or_create_by_email({:email=>email}.merge(dummy_password_attributes).merge(options))
  end
  
  def self.for_emails(emails)
    emails.map {|email| for_email(email)}.reject {|user| !user}
  end

  def self.create_without_password(params)
    self.create params.merge(dummy_password_attributes)
  end
  
  def self.dummy_password_attributes
    p = "2jljl23jlklj$%kkjhkjhk"
    {:password=>p, :password_confirmation=>p}
  end  

  def signed_up?
    last_login_at
  end
  
  def sign_up
    self.last_login_at = Time.now
  end

  def sign_up!   
    unless signed_up?
      sign_up
      save!
    end
  end
  
  def no_show_for(order)
    return if order.paid_at
    self.reputation = reputation - 4
    self.reputation = WORST_REPUTATION if self.reputation < WORST_REPUTATION
    save!
  end
  
  def picks_up(order)
    return if order.paid_at
    self.reputation = reputation + 1
    self.reputation = BEST_REPUTATION if self.reputation > BEST_REPUTATION
    save!
  end                 
  
  def reputation_s
    if reputation > 8
      "awesome"
    elsif reputation > 4
      "great"
    elsif reputation > 2
      "good"
    elsif reputation > 0
      "ok"
    elsif reputation == 0
      'neutral'
    elsif reputation > -3
      "not so good"
    else
      "unreliable"
    end
  end
  
  private
  
  def update_dob
    if @dob_day and @dob_day.length >0 and @dob_month and @dob_month.length > 0
      self.dob = Date.parse("2000-#{@dob_month}-#{@dob_day}")
    end
  end

  # TODO: Make this take the current timezone into account
  def birthday?
    now = Time.now
    dob.day == now.day and dob.mday == now.mday
  end
  
end

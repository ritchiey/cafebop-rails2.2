class User < ActiveRecord::Base

  acts_as_authentic
  easy_roles :roles
  include Gravatar
  
  def self.possible_roles
    %w/cafebop_admin claim_approver/
  end
  
  fields do  
    name                :string
    email               :string 
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
    timestamps
  end                          
  
  # This is a bit ugly. I've just placed this here to let the
  # form processed by activate_invited work.
  attr_accessor :remember_me
  
  acts_as_mappable :default_distance=>:miles
         
  has_many :votes
  has_many :claims_to_review, :class_name => "Claim", :foreign_key=>:reviewer_id, :conditions=>{:state=>'under_review'}
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts, :dependent=>:destroy
  has_many :shops, :through => :work_contracts
  has_many :friendships, :class_name =>"Friendship", :foreign_key => "user_id"
  has_many :friends, :through=>:friendships, :source=>:friend #, :order=>'email ASC'
  has_many :fanships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :fans, :through=>:fanships, :source=>:user
  has_many :orders
  
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
  
  def can_review_claims?() is_cafebop_admin?; end
  def is_admin?() is_cafebop_admin?; end

  
  def manages?(shop)
    shop.is_a?(ActiveRecord::Base) and shop = shop.id
    shop && work_contracts.exists?(:shop_id=>shop, :role=>'manager')
  end
  
  def works_at?(shop)
    shop && work_contracts.exists?(:shop_id=>shop.id, :role=>['staff', 'manager'])
  end

  def can_access_queues_of?(shop)
    shop and shop.can_have_queues? and (works_at?(shop) or is_admin?)  
  end

  def can_manage_queues_of?(shop)
    shop and shop.can_have_queues? and (manages?(shop) or is_admin?)  
  end

  def self.stats
    {
      :total => count
    }
  end

  def self.for_email(email)
    find_or_create_by_email({:email=>email}.merge(dummy_password_attributes))
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
    # TODO: Implement reputation
  end
end

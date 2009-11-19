class User < ActiveRecord::Base

  acts_as_authentic
  easy_roles :roles
  
  def self.possible_roles
    %w/cafebop_admin claim_approver/
  end
  
  fields do  
    name      :string
    email     :string 
    active    :boolean, :default=>false, :null=>false
    crypted_password  :string
    password_salt :string
    persistence_token :string   
    perishable_token :string  
    roles           :string, :default=>"--- []"
    timestamps
  end                          
  
  acts_as_mappable :default_distance=>:miles

  has_many :claims_to_review, :class_name => "Claim", :foreign_key=>:reviewer_id, :conditions=>{:state=>'under_review'}
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts
  has_many :shops, :through => :work_contracts
  has_many :friendships, :class_name=>"Friendship", :foreign_key => "user_id"
  has_many :friends, :through=>:friendships, :source=>:friend
  has_many :fanships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :fans, :through=>:fanships, :source=>:user

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/io, :on => :create
  validates_uniqueness_of :email
                                           
  def to_s() name || email; end 
  
  def active?
    active
  end     
  
  def activate!
    self.active = true
    save
  end
  
  def can_review_claims?() is_cafebop_admin?; end
  def is_admin?() is_cafebop_admin?; end

  
  def manages?(shop)
    shop && work_contracts.exists?(:shop_id=>shop.id, :role=>'manager')
  end

  def self.stats
    {
      :total => count
    }
  end
end

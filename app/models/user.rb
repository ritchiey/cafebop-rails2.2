class User < ActiveRecord::Base

  acts_as_authentic
  easy_roles :roles
  
  fields do  
    name      :string
    username  :string
    email     :string
    rpx_identifier  :string  
    crypted_password  :string
    password_salt :string
    persistence_token :string   
    perishable_token :string  
    roles           :string, :default=>"--- []"
    timestamps
  end                          

  attr_accessible :email, :password, :password_confirmation, :rpx_identifier

  has_many :claims_to_review, :class_name => "Claim", :foreign_key=>:reviewer_id, :conditions=>{:state=>'under_review'}
  has_many :claims, :dependent=>:destroy
  has_many :work_contracts
  has_many :shops, :through => :work_contracts


# Authlogic_rpx provides three hooks for mapping information from the RPX profile into your application’s user model:
# 
#     * map_rpx_data: user profile mapping during auto-registration
#     * map_rpx_data_each_login: user profile mapping during login
#     * map_added_rpx_data: user profile mapping when adding RPX to an existing account
# 
# See rpxnow.com/docs#profile_data for the definition of available attributes in the RPX profile. 


  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/io, :on => :create
  validates_uniqueness_of :email     
  validates_uniqueness_of   :username, :case_sensitive => false
        

  before_create :make_first_user_admin
                                           
  def to_s() name || email; end 
  
  def can_review_claims?
    is_cafebop_admin?
  end
  
  def manages?(shop)
    shop && work_contracts.exists?(:shop_id=>shop.id, :role=>'manager')
  end
      
private       

  def make_first_user_admin
    self.add_role('cafebop_admin') if User.count == 0    
  end
  
end

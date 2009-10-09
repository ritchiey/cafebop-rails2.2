class User < ActiveRecord::Base

  acts_as_authentic
  easy_roles :roles
  
  fields do  
    name      :string
    email     :string
    crypted_password  :string
    password_salt :string
    persistence_token :string   
    perishable_token :string  
    roles           :string, :default=>"--- []"
    timestamps
  end                          


  has_many :claims_to_review, :class_name => "Claim", :foreign_key=>:reviewer_id, :conditions=>{:state=>'under_review'}
  has_many :claims, :dependent=>:destroy

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/io, :on => :create
  validates_uniqueness_of :email
                                           
  def to_s() name || email; end 
  
  def can_review_claims?
    is_cafebop_admin?
  end
  
end

class User < ActiveRecord::Base
  
  fields do  
    name      :string
    email     :string
    crypted_password  :string
    password_salt :string
    persistence_token :string   
    perishable_token :string
    timestamps
  end                          

  has_many :claims_to_review, :class_name => "Claim", :foreign_key => :reviewer_id
  has_many :claims, :dependent=>:destroy

  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/io, :on => :create
                                           
  def to_s() name || email; end
  
  acts_as_authentic
end

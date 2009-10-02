class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :username
  
  acts_as_authentic
end

class Friendship < ActiveRecord::Base

  fields do
    timestamps
  end

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user, :friend
  validates_uniqueness_of :friend_id, :scope=>:user_id, :message=>"already exists"
  
  def friend_email=(email)
    dummy_password = "24389kjk4hjk!!hj432h2l4kjhl2h$#" 
    User.find_or_initialize_by_email(:email=>email, :password=>dummy_password, :password_confirmation=>dummy_password).tap do |friend|
      friend.active = true
      friend.save!
      self[:friend_id] = friend.id
    end
  end
  
  def friend_email
   friend ? friend.email : ""
  end
end

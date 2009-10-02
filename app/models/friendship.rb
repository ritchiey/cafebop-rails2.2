class Friendship < ActiveRecord::Base



  fields do
    timestamps
  end

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :user, :friend
  validates_uniqueness_of :friend_id, :scope=>:user_id
  
  attr_accessor :friend_email, :type => :email_address

  # --- Permissions --- #
  
  before_validation_on_create {|f| f.friend ||= User.find_or_create_by_email_address(f.friend_email)}


  def create_permitted?                                 
    return true
    acting_user.administrator? || acting_user.signed_up?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    return true
    acting_user.administrator? || user_is?(acting_user)
  end

  def view_permitted?(field)
    return true
  end

end

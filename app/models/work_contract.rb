class WorkContract < ActiveRecord::Base

  fields do
    role enum_string(:staff, :manager, :patron), :default=>'patron'
    timestamps
  end

  belongs_to :shop
  belongs_to :user



  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def update_permitted?
    return false if user_changed? || shop_changed?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def destroy_permitted?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def view_permitted?(field)
    acting_user.administrator? || shop.is_staff?(acting_user)
  end

end

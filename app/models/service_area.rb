class ServiceArea < ActiveRecord::Base



  fields do
    timestamps
  end

  belongs_to :suburb
  belongs_to :shop



  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def update_permitted?
    return false
  end

  def destroy_permitted?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def view_permitted?(field)
    true
  end

end

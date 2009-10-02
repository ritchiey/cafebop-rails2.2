class Suburb < ActiveRecord::Base



  fields do
    name  :string
    postcode  :string
    state :string
    timestamps
  end

  has_many :service_areas
  has_many :shops, :through=>:service_areas

  # --- Permissions --- #

  def create_permitted?
    acting_user.administrator?
  end

  def update_permitted?
    acting_user.administrator?
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

end

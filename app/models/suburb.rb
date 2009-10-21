class Suburb < ActiveRecord::Base


#suburb,state,postcode,lat,lng

  fields do
    name  :string
    postcode  :string
    state :string  
    lng   :float
    lat   :float
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

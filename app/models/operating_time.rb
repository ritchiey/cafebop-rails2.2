class OperatingTime < ActiveRecord::Base

  fields do                  
    days   :string
    opens  :string, :limit=>7
    closes :string, :limit=>7
    position  :integer
    timestamps
  end

  belongs_to :shop
  acts_as_list :scope=>:shop
                     
  def to_s
    "#{days} #{opens} - #{closes}"
  end                       
  
  def opens_and_closes
    "#{opens} - #{closes}"
  end

  def self.days_values
    [:Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Sunday, :Weekdays, :Weekends, :'Public Holidays', :'Weekends and Public Holidays', :'Christmas Day', :'Good Friday', :'Easter Sunday']
  end
  
  # --- Permissions --- #

  def create_permitted?
    return true if shop.community_managed? && acting_user.signed_up?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def update_permitted?
    return true if shop.community_managed? && acting_user.signed_up?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def destroy_permitted?
    return true if shop.community_managed? && acting_user.signed_up?
    acting_user.administrator? || shop.is_manager?(acting_user)
  end

  def view_permitted?(field)
    true
  end

end

class Vote < ActiveRecord::Base
  
  fields do        
    email :string
    notification_requested :boolean
    confirmed :boolean
    confirmation_key :string
    timestamps
  end
  
  belongs_to :shop, :counter_cache=>true
  belongs_to :user

end

class ShopCuisine < ActiveRecord::Base
                         
  fields do
    timestamps
  end
  
  belongs_to :shop
  belongs_to :cuisine
  
end

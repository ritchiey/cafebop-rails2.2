class Cuisine < ActiveRecord::Base      
  
  fields do
    name  :string
    timestamps
  end
  
  attr_accessible :name
  
  has_many :shop_cuisines
  has_many :shops, :through => :shop_cuisines
  
end

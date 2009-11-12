class Cuisine < ActiveRecord::Base      
  
  fields do
    name  :string
    timestamps
  end
  
  attr_accessible :name, :menu_ids
  
  has_many :shop_cuisines
  has_many :shops, :through => :shop_cuisines
  has_many :cuisine_menus
  has_many :menus, :through => :cuisine_menus
  
end

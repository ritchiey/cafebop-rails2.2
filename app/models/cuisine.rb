class Cuisine < ActiveRecord::Base      
  
  fields do
    name  :string    
    franchise  :boolean, :default=>false
    url   :string
    timestamps
  end
  
  default_scope :order=>:name
  
  attr_accessible :name, :menu_ids, :franchise, :url
  
  has_many :shop_cuisines
  has_many :shops, :through => :shop_cuisines
  has_many :cuisine_menus
  has_many :menus, :through => :cuisine_menus
  
  named_scope :is_franchise, :conditions=>{:franchise=>true}
  named_scope :is_not_franchise, :conditions=>{:franchise=>false}
  
end

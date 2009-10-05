require 'machinist/active_record'
require 'sham'

Shop.blueprint do     
  
end

Menu.blueprint do
end

MenuItem.blueprint do 
  name { CafeForgery.menu_item_name} 
end   

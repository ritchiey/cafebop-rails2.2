require 'machinist/active_record'
require 'sham'

Shop.blueprint do     
  name { NameForgery.company_name }
end

Menu.blueprint do
  shop
end

MenuItem.blueprint do 
  menu
  item_queue {ItemQueue.make(:shop=>menu.shop)}
  name { CafeForgery.menu_item_name} 
  price_in_cents {BasicForgery.number :at_least=>50, :at_most=>4500}
end                                

Order.blueprint do
  shop
end

OrderItem.blueprint do
  order
  menu_item
  quantity { BasicForgery.number }
end

ItemQueue.blueprint do
  shop
  name {BasicForgery.color.downcase}
end
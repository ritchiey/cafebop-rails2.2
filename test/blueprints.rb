require 'machinist/active_record'
require 'sham'

Sham.define do
  company_name {NameForgery.company_name}
end

Shop.blueprint do     
  name { Sham.company_name }
  street_address { "#{AddressForgery.street_address} #{AddressForgery.city}"  }
  lat { -31.9678531 }
  lng { 115.8909351 }
end

Menu.blueprint do
  shop
end

MenuItem.blueprint do 
  menu
  name { CafeForgery.menu_item_name} 
  price_in_cents {BasicForgery.number :at_least=>50, :at_most=>4500}
end                                

OperatingTime.blueprint do
  shop
  days {"Weekdays"}
  opens {"9:00am" }
  closes { "5:00pm"}
end

Order.blueprint do
  shop
end           

OrderItem.blueprint do
  order {Order.make :state=>"pending"}
  menu_item
  quantity { BasicForgery.number }
end

Flavour.blueprint do
  menu_item
  name { CafeForgery.flavor_name}
end

Size.blueprint do
  menu_item
  name { CafeForgery.size_name}
  price_in_cents {BasicForgery.number :at_least=>50, :at_most=>4500}
end

ItemQueue.blueprint do
  shop
  name {BasicForgery.color.downcase}
end

Claim.blueprint do
  shop
  user
end   

User.blueprint do
  email       { InternetForgery.email_address }
  password    "monkey"
  password_confirmation "monkey"
end              

User.blueprint :active do
  active  true
end

WorkContract.blueprint do
  shop
  user
  role 'patron'
end

Cuisine.blueprint do
  name  {CafeForgery.cuisine_name}
end

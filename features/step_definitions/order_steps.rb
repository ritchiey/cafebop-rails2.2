
Given /^I have a pending order with items at (.+?)$/ do |shop|
  shop = Shop.find_by_name(shop)
  order = Order.make(:shop=>shop, :state=>'pending')
  # Factory(:order_item, :order=>order)
  order.order_items.make
  visit "/orders/#{order.id}"
end

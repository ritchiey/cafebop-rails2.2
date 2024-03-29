
Given(/^(.+?) has a pending order with items at (.+?)$/) do |name, shop|
  name_param = (name =~ /s?he/i) ? {} : {:name=>name}
  shop = Shop.find_by_name(shop)
  menu = shop.menus.make
  menu_item = menu.menu_items.make
  quantity = 1
  visit root_path # initialize cookies
  visit shop_orders_path(menu_item.shop), :post, :order=>{
    :order_items_attributes=>[{
        :quantity=>quantity.to_s,
        :menu_item_id=>menu_item.id.to_s,
        :notes=>'from integration test'
      }
    ]
  }.merge(name_param)
  order = Order.last # TODO: this could be more robust
  visit "/orders/#{order.id}"
end            
                    
When(/^(.+?) places an order at (.+?) for the following items:$/) do |name, shop_name, table|
  name_param = (name =~ /s?he/i) ? {} : {:name=>name}
  shop = Shop.find_by_name(shop_name)
  order_item_attributes = table.hashes.map do |hash|
    menu_item = MenuItem.find_by_name(hash[:item_name]) or raise "Are you sure '#{hash[:item_name]}' is on the menu?"
    [
      {'quantity' => hash[:quantity]},
      {'menu_item_id' => menu_item.id},
      {'notes' => hash[:notes]}
    ]
  end.flatten
  visit shop_orders_path(shop),
   :post,
   :order=>{:order_items_attributes=>order_item_attributes, :phone=>'2222222'}.merge(name_param)
end

Then(/^I should see this order summary table:$/) do |expected_table|  
  html_table = tableish('table#order-summary-table tr', 'td,th').select {|r| r.size >1}
  html_table.map! { |r| r.map! { |c| c.gsub(/<.+?>/, '') } }
  expected_table.diff!(html_table)  
end

Given(/^(.*?) is inviting (.*) friends to order at (.+)$/) do |name,x, shop|
  steps %Q{
    Given #{name} has a pending order with items at #{shop}
    Then I choose to invite others
  }
end

Then(/^I choose to invite others$/) do
  steps %Q{
    Then I should see "At work?"
    When I press "Invite Friends"
  }
end

Then(/^I add "(.*?)" as a friend during the invitation$/) do |email|
  steps %Q{
    And I should see "Friend's Email"
    When I fill in "friendship[friend_email]" with "#{email}"
    And I press "Add"
    Then I should see "#{email}"
    And the "#{email}" checkbox should be checked
  }
end


Then(/^"([^\"]*)" should receive and invitation from "([^\"]*)" to order from "([^\"]*)" with a "([^\"]*)" minute limit$/) do |recipient, originator, shop, minutes|
  steps %Q{
    Then "#{recipient}" should receive an email
    When they open the email
    Then they should see "#{originator} is going to #{shop} in about #{minutes} minutes and can bring you something back" in the email body
    And they should see "If you'd like to take up the offer, go here:" in the email body
    And they should see "This message was sent on behalf of #{originator} by the Cafebop social food ordering system" in the email body
    And they should see "If you don't know who #{originator} is, you can safely ignore this message" in the email body
  }
end

Then(/^they should be able to accept the invitation$/) do
  steps %Q{
    When they click the first link in the email
    Then I should see "Your Order"
  }
end        

Then(/^I should see invited friends table$/) do |expected_table|  
  html_table = tableish('table#invited-friends tr', 'td,th')
  html_table.map! { |r| r.map! { |c| c.gsub(/<.+?>/, '') } }  
  expected_table.diff!(html_table)  
end
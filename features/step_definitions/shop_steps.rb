
Given /^there is a shop named "(.+?)"$/ do |shop_name|
  @shop = Shop.make(:name=>shop_name)
end

Given /^I am logged in as a (.+?) of (.+?)$/ do |role, shop_name|
  password = "fleabottom"
  shop = Shop.find_by_name shop_name
  user = User.make(:active, :password=>password, :password_confirmation=>password)
  shop.work_contracts.make(:user=>user, :role=>role)
  Given %Q{I am logged in as "#{user.email}" with password "#{password}"}
end

Given /^(.+?) is an? (.+?) shop$/ do |shop_name, state|
  shop = Shop.find_by_name shop_name
  shop.transition_to(state)
end

Given /^(.*) has a menu called "([^\"]*)"$/ do |shop_name, menu_name|
  shop = Shop.find_by_name shop_name
  shop.menus.make(:name=>menu_name)
end

Given /^the (.+?) menu has the following menu items:$/ do |menu_name, table|
  # table is a Cucumber::Ast::Table
  menu = Menu.find_by_name(menu_name)
  table.hashes.each do |hash|
    menu.menu_items.make(hash)
  end
end    
   
Given /^(.+?) has queuing (.+?)$/ do |shop_name, state|
  shop = Shop.find_by_name(shop_name)
  case state
    when 'enabled': shop.start_accepting_queued_orders!
    when 'disabled': shop.stop_accepting_queued_orders!
  else
    raise "Unknown state for shop queuing '#{state}'"
  end
end


Given /^the customer queue for (.+?) is (.+?)$/ do |shop_name, state|
  shop = Shop.find_by_name(shop_name)
  customer_queue = shop.customer_queues.first 
  customer_queue or raise "#{shop.name} doesn't seem to have a customer queue"
  case state 
    when 'enabled': customer_queue.start!
    when 'disabled': customer_queue.stop!
  else
    raise "Unknown state for customer queue '#{state}'"
  end
end
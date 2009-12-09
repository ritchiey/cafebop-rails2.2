
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

Given /^(.+?) is an (.+?) shop$/ do |shop_name, state|
  shop = Shop.find_by_name shop_name
  states = %w/community express professional/
  raise "Invalid state for shop" unless states.include?(state)
  above = false
  states.each do |s|
    if above
      shop.send "go_#{s}!"
      break if s == state
    else
      above = (shop.state == s)
    end
  end
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
   

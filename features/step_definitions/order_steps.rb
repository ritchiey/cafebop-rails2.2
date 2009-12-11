
Given /^I have a pending order with items at (.+?)$/ do |shop|
  shop = Shop.find_by_name(shop)
  order = Order.make(:shop=>shop, :state=>'pending')
  # Factory(:order_item, :order=>order)
  order.order_items.make
  visit "/orders/#{order.id}"
end            


Given /^I am inviting my friends to order at (.+)$/ do |shop|
  steps %Q{
    Given I have a pending order with items at #{shop}
    Then I should see "At work?"
    When I press "Offer Friends"
	  Then I should see "See if you're friends or colleagues want anything while you're there. The email they receive will read"
	  And I should see "is going to #{shop}"
  }
end

Then /^I add "([^\"]*)" as a friend during the invitation$/ do |email|
  steps %Q{
    And I should see "Friend's Email"
    When I fill in "friendship[friend_email]" with "#{email}"
    And I press "Add"
    Then I should see "#{email}"
    And the "#{email}" checkbox should be checked
  }
end
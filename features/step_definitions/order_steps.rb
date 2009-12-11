
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


Then /^"([^\"]*)" should receive and invitation from "([^\"]*)" to order from "([^\"]*)" with a "([^\"]*)" minute limit$/ do |recipient, originator, shop, minutes|
  steps %Q{
    Then "#{recipient}" should receive an email
    When they open the email
    Then they should see "#{originator} is going to #{shop} in about #{minutes} minutes and can bring you something back" in the email body
    And they should see "If you'd like to take up the offer, go here:" in the email body
    And they should see "This message was sent on behalf of #{originator} by the Cafebop social food ordering system" in the email body
    And they should see "If you don't know who #{originator} is, you can safely ignore this message" in the email body
  }
end

Then /^they should be able to accept the invitation$/ do
  steps %Q{
    When they click the first link in the email
    Then I should see "Your Order"
  }
end
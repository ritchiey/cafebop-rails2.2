  
Given /^the following user records?$/ do |factory, table|
  table.hashes.each do |hash|
    # Factory(factory, hash)
    User.make(hash.merge(:password_confirmation=>hash[:password]))
  end
end

Given /^there is an active user with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  User.make(:active=>true, :email=>email, :password=>password, :password_confirmation=>password)
  unless User.email_eq(email).first.active
    raise "Account not active"
  end
end


Given /^I am logged in as "(.+?)" with password "(.+?)"$/ do |email, password|
  visit "/login"
  fill_in "user_session_email", :with=>email
  fill_in "user_session_password", :with=>password
  click_button "Login"
end

Given /^"([^\"]*)" has a friend with email "([^\"]*)"$/ do |user_email, friend_email|
  user = User.email_eq(user_email).first
  user or raise "No existing user with email #{user_email}"
  friend = User.make(:active=>true, :email=>friend_email)
  user.friends << friend
  user.save!
end

Then /^"([^\"]*)" should receive an activation email$/ do |email|
  steps %Q{
    Then "#{email}" should receive an email
    When they open the email
    Then they should see "Please visit the following web address to activate your cafebop.com account" in the email body
  }
end

When /^I activate the account for "([^\"]*)"$/ do |email|
  steps %Q{
    When I click the first link in the email
    Then I should see "Your Cafebop account is now active! Welcome aboard."
  }
end     

Given /^I sign up as "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  steps %Q{
    Given I am on the signup page
    And I complete the signup form as "#{email}" with password "#{password}"
  }
end

Given /^I complete the signup form as "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  steps %Q{
    And I fill in "user[email]" with "#{email}"
    And I fill in "user[password]" with "#{password}"
    And I fill in "user[password_confirmation]" with "#{password}"
    And I press "Sign up"
    Then I should see "Thanks for signing up! Check your email to permanently activate your account."
    And "#{email}" should receive an email
    When I open the email
    Then I should see "Thanks for joining Cafebop" in the email body
    When I click the first link in the email
    Then I should see "Your Cafebop account is now active! Welcome aboard."
  }
end
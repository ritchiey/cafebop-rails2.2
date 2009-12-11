  
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

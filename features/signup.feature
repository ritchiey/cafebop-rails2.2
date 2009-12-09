Feature: Signup
  In order to register new users
  As a new user
  I want to be able to register with the site and verify my details.

Scenario: A new person signs up
    Given I am on the signup page
    And I fill in "user[email]" with "example@example.com"
		And I fill in "user[password]" with "secret"
		And I fill in "user[password_confirmation]" with "secret"
    And I press "Sign up"
    Then I should see "Thanks for signing up! Check your email to permanently activate your account."
    And I should receive an email
    When I open the email
    Then I should see "Thanks for joining cafebop.com\n\nPlease visit the following web address to activate your cafebop.com account:\n\n" in the email body
    When I click the first link in the email
    # Then I should see "Terms and Conditions"
    # And I press "I Agree"    
    Then I should be on the homepage
    And I should see "Your Cafebop account is now active! Welcome aboard."

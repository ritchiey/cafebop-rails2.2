Feature: Signup
  In order to register new users
  As a new user
  I want to be able to register with the site and verify my details.

Scenario: A new person signs up
    Given I sign up as "luna@hogwarts.edu" with password "Quibbler"
    Then I should be on the homepage

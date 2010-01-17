Feature: Claiming Shops
  In order allow users to claim shops
  As an administrator of the system
  I want the shop claiming workflow works

  Background:
    Given there is an active user with email "dumbledore@hogwarts.edu" and password "Welcome"
    And there is an active user with email "fred@hogwarts.edu" and password "shortcut"
	  And there is a shop named "WWW"
	  And WWW is a community shop


  Scenario: An authenticated user can lodge a claim for a shop and be rejected
    Given I am logged in as "fred@hogwarts.edu" with password "shortcut"
    And I am on the ordering screen for WWW
    Then I should see "WWW"
    When I follow "Claim this Shop"
    Then I should see "By pressing Claim Now below, you are asserting that you are the manager and/or owner of WWW and that you agree to be bound by the shop owners terms"
    When I fill in "First name" with "Fred"
    And I fill in "Last name" with "Weasley"
    And I fill in "Agreement" with "i agree"
    And I press "Claim Now"
    Then I should be on the ordering screen for WWW
    And I should see "Your claim for WWW has been registered. We'll be in touch."

  Scenario: An authenticated user can lodge a claim for a shop and be accepted
	  
  Scenario: An unauthenticated user must authenticate to claim a shop
    Given I am on the ordering screen for WWW
    And I follow "Claim this Shop"
    Then I should be on the login page
    And I should see "Please login or register to lodge a claim."

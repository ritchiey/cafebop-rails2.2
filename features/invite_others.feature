Feature: Invite others
  In order to send invitations for group ordering
  As a person who's going to the shop
  I want to test that the invitational emails go out

  Background:
    Given there is an active user with email "harry@hogwarts.edu" and password "Quiddich"
    And "harry@hogwarts.edu" has a friend with email "hermione@hogwarts.edu"
	  And there is an active shop named "Gromits"
		And Gromits has a menu called "Breakfast"
		And the Breakfast menu has the following menu items:
	 | name   | description                    | price |
	 | coffee | Delicious Cafeine Laden coffee | 380  |
	 | toast  | Straight from our toaster      | 200  |
      

  Scenario: Sending and accepting an order as an authenticated user
    Given I am logged in as "harry@hogwarts.edu" with password "Quiddich"
    And he is inviting his friends to order at Gromits
    Then the "hermione@hogwarts.edu" checkbox should be checked
    When I select "5" from "order[minutes_til_close]"
    And I press "Continue"
    Then I should see invited friends table
      | Friend   | Status  |
      | hermione | invited |
    Then "hermione@hogwarts.edu" should receive and invitation from "harry" to order from "Gromits" with a "5" minute limit

	Scenario: Sending and accepting an order as an existing user
    Given Harry is inviting his friends to order at Gromits
    Then I should see "You'll need a Cafebop account to invite others"
    And I should see "Already a Cafebop member?"
    When I follow "Login"
    And I fill in "Email" with "harry@hogwarts.edu"
    And I fill in "Password" with "Quiddich"
    And I press "Login"
    Then I should see "Logged in as harry"
    When I press "Invite Friends"
    And I add "ron@hogwarts.edu" as a friend during the invitation
    When I press "Continue"
    Then I should see invited friends table
      | Friend   | Status  |
      | hermione | invited |
      | ron      | invited |
    Then "ron@hogwarts.edu" should receive and invitation from "harry" to order from "Gromits" with a "10" minute limit
    And they should be able to accept the invitation
    #     When I press "Show Me the Menu"
    #     Then I should see "Gromits"

	Scenario: Sending and accepting an order as an new user
    Given Neville is inviting his friends to order at Gromits   
    Then I should see "You'll need a Cafebop account to invite others"
    And I complete the signup form as "neville@hogwarts.edu" with password "Quibbler"
    Then I should see "You have Outstanding Orders..."  
    When I follow "Gromits" within "#my-orders"  
    And I choose to invite others
    And I add "ron@hogwarts.edu" as a friend during the invitation
    And I add "hermione@hogwarts.edu" as a friend during the invitation
    And I uncheck "ron@hogwarts.edu"
    And I add "harry@hogwarts.edu" as a friend during the invitation
    When I press "Continue"
    Then I should see invited friends table
      | Friend   | Status  |
      | harry    | invited |
      | hermione | invited |
    
      
  Scenario: Resuming and completing order without inviting anyone
    Given I am logged in as "harry@hogwarts.edu" with password "Quiddich"
    And he has a pending order with items at Gromits
    When I follow "home"
    Then I should see "You have Outstanding Orders..."   
    When I follow "Gromits" within "#my-orders"  
    And I press "Pay in Shop"
    #Then I should not send any invites
  
      
      

Feature: Invite others
  In order to send invitations for group ordering
  As a person who's going to the shop
  I want to test that the invitational emails go out

  Background:
    Given there is an active user with email "harry@hogwarts.edu" and password "Quiddich"
    And "harry@hogwarts.edu" has a friend with email "hermione@hogwarts.edu"
	  And there is a shop named "Gromits"
		And Gromits has a menu called "Breakfast"
		And the Breakfast menu has the following menu items:
	 | name   | description                    | price |
	 | coffee | Delicious Cafeine Laden coffee | 380  |
	 | toast  | Straight from our toaster      | 200  |
      

  Scenario: Sending and accepting an order as an authenticated user
    Given I am logged in as "harry@hogwarts.edu" with password "Quiddich"
    And I am inviting my friends to order at Gromits
    Then the "hermione@hogwarts.edu" checkbox should be checked
    When I select "5" from "order[minutes_til_close]"
    And I press "Continue"
    Then I should see invited friends table
      | Friend                | Status  |
      | hermione@hogwarts.edu | invited |    
    Then "hermione@hogwarts.edu" should receive and invitation from "harry" to order from "Gromits" with a "5" minute limit

	Scenario: Sending and accepting an order as an existing user
    Given I am inviting my friends to order at Gromits
	  # Initial invite page
    And I fill in "order[user_email]" with "harry@hogwarts.edu"
    And I select "5" from "order[minutes_til_close]"
    And I press "Continue"
    # Login     
    And the "Email" field should contain "harry@hogwarts.edu"
    And I fill in "user_session_password" with "Quiddich"
    And I press "Continue"
    Then I should see "Logged in as harry"
    #And the "minutes" field should contain "5" # doesn't work
    And I add "ron@hogwarts.edu" as a friend during the invitation
    When I press "Continue"
    Then "ron@hogwarts.edu" should receive and invitation from "harry" to order from "Gromits" with a "5" minute limit
    And they should be able to accept the invitation
    #     When I press "Show Me the Menu"
    #     Then I should see "Gromits"

  	Scenario: Sending and accepting an order as an new user
      Given I am inviting my friends to order at Gromits
      And I fill in "order[user_email]" with "neville@hogwarts.edu"
      And I select "5" from "order[minutes_til_close]"
      And I press "Continue"  
      Then "neville@hogwarts.edu" should receive an activation email
      When I activate the account for "neville@hogwarts.edu"
      Then I should see "You have Outstanding Orders..."   
      #When I follow "Gromits" within "my-orders"
      
      
      
      

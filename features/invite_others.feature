Feature: Invite others
  In order to send invitations for group ordering
  As a person who's going to the shop
  I want to test that the invitational emails go out

  Background:
    Given there is an active user with email "harry@hogwarts.edu" and password "Quiddich"
	  And there is a shop named "Gromits"
		And Gromits has a menu called "Breakfast"
		And the Breakfast menu has the following menu items:
	 | name   | description                    | price |
	 | coffee | Delicious Cafeine Laden coffee | 380  |
	 | toast  | Straight from our toaster      | 200  |

  @focus
	Scenario: Sending and accepting an order as an existing user
	  Given I have a pending order with items at Gromits
	  Then I should see "At work?"
	  When I press "Offer Friends"
	  # Initial invite page
	  Then I should see "See if you're friends or colleagues want anything while you're there. The email they receive will read"
	  And I should see "is going to Gromits"
    And I fill in "order[user_email]" with "harry@hogwarts.edu"
    And I select "5" from "order[minutes_til_close]"
    And I press "Continue"
    # Login     
    And the "Email" field should contain "harry@hogwarts.edu"
    And I fill in "user_session_password" with "Quiddich"
    And I press "Continue"
    Then I should see "Logged in as harry"
    # Add a friend
    And I should see "Friend's Email"
    When I fill in "friendship[friend_email]" with "ron@hogwarts.edu"
    And I press "Add"
    Then I should see "ron@hogwarts.edu"
    When I press "Continue"
    Then I should receive an email
    When I open the email
    #     Then I should see "harry is going to Gromits and can pick something up for you there." in the email body
    #     And I should see "If you would like anything, click the link below to place your order:" in the email body
    #     And I should see "This message was sent from Cafebop on behalf of" in the email body
    #     When I click the first link in the email
    #     Then I should see "Respond to Invitation"
    #     When I press "Show Me the Menu"
    #     Then I should see "Gromits"

  	Scenario: Sending and accepting an order as an new user
  	  Given I have a pending order with items at Gromits
  	  Then I should see "At work?"
  	  When I press "Offer Friends"
  	  Then I should see "See if you're friends or colleagues want anything while you're there. The email they receive will read"
  	  And I should see "is going to Gromits"
      And I fill in "order[user_email]" with "hermione@cafebop.com"
      And I select "5" from "order[minutes_til_close]"
      And I press "Continue"
      # And I should see "An activation email has been sent to harry@hogwarts.edu."
      # And I should receive an email    
      
      
    Scenario: Logging in with an active user
  	  When I am logged in as "harry@hogwarts.edu" with password "Quiddich"
  	  Then I should see "Logged in as harry"

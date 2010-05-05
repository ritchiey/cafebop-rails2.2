Feature: Signup
  In order to encourage use of our service, I want to make it as easy
  as possible to create a shop and user.
  

Scenario: An new user creates a shop
    Given I am on the home page
    And I follow "Create your Shop"
    Then I should see "Pricing & Signup"
    When I follow "Sign Up"
    Then I should see "Create your Shop"
    When I fill in the following:
      | Email Address  | ron@hogwarts.edu     |
      | Name           | Scabbers             |
      | Street address | 9 Hedge Rd Hogsmeade |
      | Phone          | 2222222              |
      | URL            | scabbers             |
    And press "Create Shop" 
    Then "ron@hogwarts.edu" should receive an email
    When I open the email
    Then I should see "This is the activation code for your new shop" in the email body
    And I should see "Please enter this code on the Email Confirmation screen" in the email body
    When I fill in "Activation Code" with "XXXX"
    And press "Continue"
    Then I should see "Invalid activation code"
    When I enter the activation code from the email
    And press "Continue"
    Then I should see "Nice One!"
    And I should see "Your shop Scabbers is now online at http://scabbers.example.com"
    

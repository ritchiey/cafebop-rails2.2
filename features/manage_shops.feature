Feature: Manage Shops
  In order to manage a shop
  As a shop owner
  I want to create and manage menus

  Scenario: Creating a Menu
    Given there is a shop named "Bulbousity"     
    And Bulbousity is an express shop
    And I am logged in as a manager of Bulbousity
    And I am on the shop Bulbousity's edit page
    Then I should see "Bulbousity"
    When I follow "Add Menu"
    And I fill in "menu[name]" with "Supper"
    And I press "Create Menu"
    Then I should see "Edit Menu"
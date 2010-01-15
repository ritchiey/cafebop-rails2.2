Feature: Ordering
  In order to verify that we can place orders
  As a customer
  I want to place an order and verify that the order items appear in the appropriate queues

        
  Background:
	  Given there is a shop named "Gromits"
	  And Gromits is an express shop
		And Gromits has a menu called "Breakfast"
		And the Breakfast menu has the following menu items:
	 | name   | description                    | price_in_cents |
	 | coffee | Delicious Cafeine Laden coffee | 380            |
	 | toast  | Straight from our toaster      | 200            |

  Scenario: Placing an order
    When I am on the ordering screen for Gromits
    Then I should see "coffee"
    And I should see "Delicious Cafeine Laden coffee"
    And I should see "3.80"                       
    And I should see "toast"
    And I should see "Straight from our toaster"
    And I should see "2.00"
    When Harry places an order at Gromits for the following items:
      | quantity | item_name | notes       |
      | 1        | coffee    | extra sugar |
      | 2        | toast     |             |
    Then I should see this order summary table:
      | Qty | Description | Cost($) |             |
      | 1   | coffee      | $3.80   | extra sugar |
      | 2   | toast       | $4.00   |             |
      |     | Total       | $7.80   |             |
    When I press "Pay In Shop"
    Then I should see this order summary table:
      | Qty | Description | Cost($) |             | Made |
      | 1   | coffee      | $3.80   | extra sugar |      |
      | 2   | toast       | $4.00   |             |      |
      |     | Total       | $7.80   |             |      |


    Scenario: Placing an order when queuing is enabled for the shop
      Given Gromits has queuing enabled
      And the customer queue for Gromits is enabled
      When I am on the ordering screen for Gromits
      Then I should see "coffee"
      And I should see "Delicious Cafeine Laden coffee"
      And I should see "3.80"                       
      And I should see "toast"
      And I should see "Straight from our toaster"
      And I should see "2.00"
      When Hermoine places an order at Gromits for the following items:
        | quantity | item_name | notes       |
        | 1        | coffee    | extra sugar |
        | 2        | toast     |             |
      Then I should see this order summary table:
        | Qty | Description | Cost($) |             |
        | 1   | coffee      | $3.80   | extra sugar |
        | 2   | toast       | $4.00   |             |
        |     | Total       | $7.80   |             |
      When I press "Pay In Shop"
      Then I should see this order summary table:
        | Qty | Description | Cost($) | Status |             |
        | 1   | coffee      | $3.80   | queued | extra sugar |
        | 2   | toast       | $4.00   | queued |             |
        |     | Total       | $7.80   |        |             |

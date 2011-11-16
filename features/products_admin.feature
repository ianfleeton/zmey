Feature: Products Administration

  Scenario: Delete a product
    Given I am logged in as an administrator
    And there is one product in the shop
    And I am on the products page
    When I follow "Delete"
    Then I should see "Product deleted."
    And I should see "No products"

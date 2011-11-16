Feature: Products Administration

  Scenario: New product
    Given I am logged in as an administrator
    And I am on the new product page
    When I fill in "SKU" with "EPI-SG"
    And I fill in "Name" with "Epiphone SG"
    And I press "Create Product"
    Then I should see "Successfully added new product."

  Scenario: Delete a product
    Given I am logged in as an administrator
    And there is one product in the shop
    And I am on the products page
    When I follow "Delete"
    Then I should see "Product deleted."
    And I should see "No products"

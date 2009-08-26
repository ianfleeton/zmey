Feature: Shop Checkout

  As a shopper
  I need to submit my details to place an order
  
  Scenario: Redirect to basket when basket is empty
    Given my basket is empty
    When I am on the checkout page
    Then I should be on the view basket page
    And I should see "empty"

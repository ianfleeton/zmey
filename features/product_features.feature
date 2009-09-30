Feature: Product Features

  Products can have features that can be chosen or specified by customers.
  Features can be a selection of options, for example, the size of a T-shirt or
  they can be free-form text fields, for example, a person's name to use
  when engraving.
  
  Scenario: There should be an edit link besides a product's features when an administrator is logged in
    Given a product with features
    And I am logged in as an administrator
    When I am on the homepage
    Then I should see "Edit feature"

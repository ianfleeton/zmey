Feature: Website Management

  In order to set up and manage websites for clients
  As an employee of Your e Solutions
  I want to be able to administer websites from a web-based interface
  
  Scenario: See a list of websites
    Given I am on the list websites page
    Then I should see "Websites"
    And I should see a list of websites
    And I should see links to edit websites
    And I should see a link to add a new website
    
  Scenario: Form for creating a new website displays
    Given I am on the new website page
    Then I should see "New Website"
    And I should see "Subdomain"
    And I should see "Domain"
    And I should see "Google Analytics code"
    And I should see "Name"
    And I should see "Email"

  Scenario: Creating a new website
    Given I am on the new website page
    And I fill in "Subdomain" with "acme"
    And I fill in "Domain" with "www.acme.com"
    And I fill in "Google Analytics code" with "UA-0000000-2"
    And I fill in "Name" with "Acme Corporation"
    And I fill in "Email" with "sales@acmecorporation.com"
    And I press "Create New Website"
    Then I should be on the create website page
    And I should be redirected to the list websites page
    And I should see "added new website"
    And a new website should exist with the domain "www.acme.com"

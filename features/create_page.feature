Feature: Creating new pages

  As a site owner with new content
  I want to create new pages on my website
  
  Scenario: Form for creating a new page displays
    Given I am logged in as an administrator
    When I am on the new page page
    Then I should see "New Page"
    And I should see "Title"
    And I should see "Meta tags"
    And I should see "Content"

  Scenario: Creating a new page without filling in any details
    Given I am logged in as an administrator
    When I am on the new page page
    And I press "Create New Page"
    Then I should see "5 errors"

  Scenario: Creating a new page with a bad slug
    Given I am logged in as an administrator
    When I am on the new page page
    And I fill in "Slug" with "*"
    And I press "Create New Page"
    Then I should see "Slug can only contain lowercase letters, numbers and hyphens"
    And I should be on the pages page

  Scenario: Creating a new page
    Given I am logged in as an administrator
    When I am on the new page page
    And I fill in "Title" with "Buying a Guitar - A Rich Idiot's Guide"
    And I fill in "Name" with "Buying a Guitar"
    And I fill in "Slug" with "guitar-buying-faq"
    And I fill in "Description" with "dolor sit"
    And I press "Create New Page"
    Then I should be on the new page page
    And I should see "added new page"
    And a new page should exist with the slug "guitar-buying-faq"

  Scenario: Deleting a page
    Given I am logged in as an administrator
    And I am on the home page
    And I follow "About"
    When I press "Delete Page"
    Then I should see "Page deleted."

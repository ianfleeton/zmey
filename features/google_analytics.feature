Feature: Google Analytics tracking code

  In order to fine tune my website
  As a website owner
  I want visits to my website tracked using Google Analytics
  
  Scenario: Website that has tracking code
    Given a website with tracking code
    And I am on the homepage
    Then I should find the correct tracking code

  Scenario: Website that has no tracking code
    Given a website without tracking code
    And I am on the homepage
    Then I should not find tracking code

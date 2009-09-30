Feature: Can Users Create Accounts?

  Some sites will want users to be able to create accounts; others won't
  
  Scenario: Join link in menu
    Given a website where users can create accounts
    When I am on the homepage
    Then I should see "Join"

  Scenario: No join link in menu
    Given a website where users cannot create accounts
    When I am on the homepage
    Then I should not see "Join"

  Scenario: Invitation to create an account
    Given a website where users can create accounts
    When I am on the login page
    Then I should see "Create your account now"

  Scenario: No invitation to create an account
    Given a website where users cannot create accounts
    When I am on the login page
    Then I should not see "Create your account now"

  Scenario: Create account page displays
    Given a website where users can create accounts
    When I am on the create account page
    Then I should be on the create account page

  Scenario: Create account page redirects to homepage
    Given a website where users cannot create accounts
    When I am on the create account page
    Then I should be on the homepage

  Scenario: Create account page displays for administrators regardless
    Given a website where users cannot create accounts
    And I am logged in as an administrator
    When I am on the create account page
    Then I should be on the create account page

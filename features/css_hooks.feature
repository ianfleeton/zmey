Feature: CSS hooks

  In order to enforce my brand identity through my website and tailor
  pages for their different content
  As a merchant
  I want my web designer to be able to customise my site's design

  Scenario: Pages have different <body> class attributes
    When I am on the about page
    Then I should see a "body" tag with a class of "about"

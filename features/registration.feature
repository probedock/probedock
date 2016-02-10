@acceptance
Feature: New user registration

  Users should be able to register an account on Probe Dock if the feature is enabled.



  Scenario: A user should be able to register a new account
    When user registrations are enabled
    And the user visits /
    And clicks on the register button

@api @app-settings
Feature: Application settings

  Probe Dock administrators can configure application-wide settings.
  Other users should be able to retrieve those settings.



  Scenario: A Probe Dock administrator should be able to update application settings.
    Given user yoda who is a Probe Dock admin exists
    And user registrations are disabled
    When yoda sends a PATCH request with the following JSON to /api/appSettings:
      """
      {
        "userRegistrationEnabled": true
      }
      """
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "userRegistrationEnabled": true,
        "updatedAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: true
      updatedAt: "@json(/updatedAt)"
      """



  @authorization
  Scenario: An organization admin should not be able to update application settings.
    Given organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    And user registrations are disabled
    When palpatine sends a PATCH request with the following JSON to /api/appSettings:
      """
      {
        "userRegistrationEnabled": true
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  @authorization
  Scenario: An organization member should not be able to update application settings.
    Given organization Galactic Republic exists
    And user jjbinks who is a member of Galactic Republic exists
    And user registrations are disabled
    When jjbinks sends a PATCH request with the following JSON to /api/appSettings:
      """
      {
        "userRegistrationEnabled": true
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  @authorization
  Scenario: An anonymous user should not be able to update application settings.
    Given user registrations are disabled
    When nobody sends a PATCH request with the following JSON to /api/appSettings:
      """
      {
        "userRegistrationEnabled": true
      }
      """
    Then the response should be HTTP 401 with the following errors:
      | message             |
      | Missing credentials |
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  Scenario: A Probe Dock administrator should be able to retrieve application settings.
    Given user yoda who is a Probe Dock admin exists
    And user registrations are disabled
    When yoda sends a GET request to /api/appSettings
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "userRegistrationEnabled": false,
        "updatedAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  Scenario: An organization admin should be able to retrieve application settings.
    Given organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/appSettings
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "userRegistrationEnabled": false,
        "updatedAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  Scenario: An organization member should be able to retrieve application settings.
    Given organization Galactic Republic exists
    And user jjbinks who is a member of Galactic Republic exists
    And user registrations are disabled
    When jjbinks sends a GET request to /api/appSettings
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "userRegistrationEnabled": false,
        "updatedAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """



  Scenario: An anonymous user should be able to retrieve application settings.
    Given user registrations are disabled
    When nobody sends a GET request to /api/appSettings
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "userRegistrationEnabled": false,
        "updatedAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following app settings should be in the database:
      """
      userRegistrationEnabled: false
      """

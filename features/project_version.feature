@api @project-version
Feature: Project version

  Users should be able to retrieve project versions.

  The details of a test contains:
  - name
  - project id
  - creation date



  Background:
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.0.1 exists for project X-Wing since 2 days ago
    And project version 1.0.0 exists for project X-Wing since 1 day ago
    And project Y-Wing exists within organization Rebel Alliance
    And project version a exists for project Y-Wing since 10 days ago
    And project version b exists for project Y-Wing since 5 days ago



  Scenario: An organization member should be able to get project versions in his organization
    When hsolo sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "name": "1.0.0",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "name": "1.0.1",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "name": "b",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "name": "a",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get project versions for a specific project
    When hsolo sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "name": "1.0.0",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "name": "1.0.1",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get project versions without specifying the organization
    When hsolo sends a GET request to /api/projectVersions
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get project versions of a private organization
    Given private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    When palpatine sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get project versions of a project in a private organization
    Given private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    When palpatine sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get project versions without specifying the organization
    When nobody sends a GET request to /api/projectVersions
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get project versions of a private organization
    When nobody sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted


  @authorization
  Scenario: An anonymous user should not be able to get project versions of a project in a private organization
    When nobody sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

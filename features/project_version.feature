@api @project-version
Feature: Project version

  Users should be able to retrieve project versions.

  The details of a project version contains:
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



  Scenario: An anonymous member should be able to get project versions from a public organization
    Given public organization Old Republic exists
    And user jjbinks who is a member of Old Republic exists
    And project Jedi Temple exists within organization Old Republic
    And project version 2.0.1 exists for project Jedi Temple since 2 days ago
    And project version 2.0.0 exists for project Jedi Temple since 1 day ago
    And project Senate exists within organization Old Republic
    And project version 3.0.0 exists for project Senate since 1 day ago
    When nobody sends a GET request to /api/projectVersions?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "name": "2.0.0",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "name": "2.0.1",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "name": "3.0.0",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous member should be able to get project versions for a project in a public organization
    Given public organization Old Republic exists
    And user jjbinks who is a member of Old Republic exists
    And project Jedi Temple exists within organization Old Republic
    And project version 2.0.1 exists for project Jedi Temple since 2 days ago
    And project version 2.0.0 exists for project Jedi Temple since 1 day ago
    And project Senate exists within organization Old Republic
    And project version 3.0.0 exists for project Senate since 1 day ago
    When nobody sends a GET request to /api/projectVersions?projectId={@idOf: Jedi Temple}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "name": "2.0.0",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "name": "2.0.1",
        "projectId": "@idOf: Jedi Temple",
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
  Scenario: A user should not be able to get the versions of a project in a private organization
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
  Scenario: An anonymous user should not be able to get the versions of a project in a private organization
    When nobody sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

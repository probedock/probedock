@api @project
Feature: Creation of a project

  Users should be able to create a new project.



  Background:
    # Create private organization with 1 user
    Given private organization Rebel Alliance exists
    And user hsolo who is an admin of Rebel Alliance exists

    # Create a second organization
    And public organization Old Republic exists
    And user jjbinks who is an admin of Old Republic exists



  Scenario: An organization admin should be able to create a project in his organization
    When hsolo sends a POST request with the following JSON to /api/projects:
      """
      {
        "displayName": "Project",
        "name": "project",
        "organizationId": "@idOf: Rebel Alliance"
      }
      """
    Then the response should be HTTP 201 with the following JSON:
      """
      {
        "id": "@alphanumeric",
        "name": "project",
        "displayName": "Project",
        "organizationId": "@idOf: Rebel Alliance",
        "testsCount": 0,
        "createdAt": "@iso8601",
        "updatedAt": "@iso8601"
      }
      """
    And the following changes should have occurred: +1 project



  Scenario: An organization admin should be able to create a project in his organization with a repo URL
    When hsolo sends a POST request with the following JSON to /api/projects:
      """
      {
        "displayName": "Project",
        "name": "project",
        "repoUrl": "http://localhost.localdomain",
        "organizationId": "@idOf: Rebel Alliance"
      }
      """
    Then the response should be HTTP 201 with the following JSON:
      """
      {
        "id": "@alphanumeric",
        "name": "project",
        "displayName": "Project",
        "organizationId": "@idOf: Rebel Alliance",
        "repoUrl": "http://localhost.localdomain",
        "testsCount": 0,
        "createdAt": "@iso8601",
        "updatedAt": "@iso8601"
      }
      """
    And the following changes should have occurred: +1 project



  Scenario: An organization admin should be able to create a project in his organization with a repo URL pattern
    When hsolo sends a POST request with the following JSON to /api/projects:
      """
      {
        "displayName": "Project",
        "name": "project",
        "repoUrl": "http://localhost.localdomain",
        "repoUrlPattern": "/blob/{{ commit }}/{{ file }}#L{{ line }}",
        "organizationId": "@idOf: Rebel Alliance"
      }
      """
    Then the response should be HTTP 201 with the following JSON:
      """
      {
        "id": "@alphanumeric",
        "name": "project",
        "displayName": "Project",
        "organizationId": "@idOf: Rebel Alliance",
        "repoUrl": "http://localhost.localdomain",
        "repoUrlPattern": "/blob/{{ commit }}/{{ file }}#L{{ line }}",
        "testsCount": 0,
        "createdAt": "@iso8601",
        "updatedAt": "@iso8601"
      }
      """
    And the following changes should have occurred: +1 project



  @authorization
  Scenario: An organization admin should not be able to create a project in a private organization
    When jjbinks sends a POST request with the following JSON to /api/projects:
      """
      {
        "displayName": "Project",
        "name": "project",
        "organizationId": "@idOf: Rebel Alliance"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization admin should not be able to create a project in a private organization
    When nobody sends a POST request with the following JSON to /api/projects:
      """
      {
        "displayName": "Project",
        "name": "project",
        "organizationId": "@idOf: Rebel Alliance"
      }
      """
    Then the response should be HTTP 401 with the following errors:
      | message             |
      | Missing credentials |
    And nothing should have been added or deleted
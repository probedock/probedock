@api @organizations
Feature: Organization accessibility

  The details of Probe Dock organizations should only be accessible by authorized users.
  Anyone is authorized to access a public organization, including anonymous users.
  For private organizations, authorized users include organization members, organization admins and Probe Dock admins.



  @authorization @scoping
  Scenario: An anonymous user should only see public organizations as accessible
    Given public organization Galactic Republic exists
    And private organization Rebel Alliance exists
    And private organization Sith Order exists
    When nobody sends a GET request to /api/organizations?accessible=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: Galactic Republic",
          "name": "galactic-republic",
          "displayName": "Galactic Republic",
          "public": true,
          "projectsCount": 0,
          "membershipsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  @authorization @scoping
  Scenario: An organization member should see public organizations and organizations he is a member of as accessible
    Given public organization Galactic Republic exists
    And private organization Rebel Alliance exists
    And private organization Sith Order exists
    And user hsolo who is a member of Rebel Alliance exists
    When hsolo sends a GET request to /api/organizations?accessible=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: Galactic Republic",
          "name": "galactic-republic",
          "displayName": "Galactic Republic",
          "public": true,
          "projectsCount": 0,
          "membershipsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        {
          "id": "@idOf: Rebel Alliance",
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "public": false,
          "projectsCount": 0,
          "membershipsCount": 1,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }
      ]
      """



  @authorization @scoping
  Scenario: An organization admin should see public organizations and organizations he is a member of as accessible
    Given public organization Galactic Republic exists
    And private organization Rebel Alliance exists
    And private organization Sith Order exists
    And user borgana who is an admin of Rebel Alliance exists
    When borgana sends a GET request to /api/organizations?accessible=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: Galactic Republic",
          "name": "galactic-republic",
          "displayName": "Galactic Republic",
          "public": true,
          "projectsCount": 0,
          "membershipsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        {
          "id": "@idOf: Rebel Alliance",
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "public": false,
          "projectsCount": 0,
          "membershipsCount": 1,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }
      ]
      """



  @authorization @scoping
  Scenario: A Probe Dock administrator should see all organizations as accessible
    Given public organization Galactic Republic exists
    And private organization Rebel Alliance exists
    And private organization Sith Order exists
    And user yoda who is a Probe Dock admin exists
    And user yoda is a member of Rebel Alliance
    When yoda sends a GET request to /api/organizations?accessible=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: Galactic Republic",
          "name": "galactic-republic",
          "displayName": "Galactic Republic",
          "public": true,
          "projectsCount": 0,
          "membershipsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        {
          "id": "@idOf: Rebel Alliance",
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "public": false,
          "projectsCount": 0,
          "membershipsCount": 1,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        {
          "id": "@idOf: Sith Order",
          "name": "sith-order",
          "displayName": "Sith Order",
          "public": false,
          "projectsCount": 0,
          "membershipsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }
      ]
      """

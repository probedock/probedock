@api @organization
Feature: Organization

  Retrieve the list of organization with filters:
  - administered



  Background:
    # Create three organizations
    Given public organization Old Republic exists
    And private organization Rebel Alliance exists
    And private organization Galactic Empire exists

    # Set three memberships to the same user
    And user borgana who is an admin of Old Republic exists
    And user borgana is also an admin of Rebel Alliance
    And user borgana is also a member of Galactic Empire



  Scenario: A user should only be able to retrieve the organization where he is an admin.
    When borgana sends a GET request to /api/organizations?administered=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: Old Republic",
        "name": "old-republic",
        "displayName": "Old Republic",
        "public": true,
        "projectsCount": 0,
        "membershipsCount": 1,
        "createdAt": "@iso8601",
        "updatedAt": "@iso8601"
      }, {
        "id": "@idOf: Rebel Alliance",
        "name": "rebel-alliance",
        "displayName": "Rebel Alliance",
        "public": false,
        "projectsCount": 0,
        "membershipsCount": 1,
        "createdAt": "@iso8601",
        "updatedAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A anonymous user should not be able to retrieve any organization when administered filter is set.
    When nobody sends a GET request to /api/organizations?administered=true
    Then the response should be HTTP 401 with the following errors:
      | message                                        |
      | Missing credentials |
    And nothing should have been added or deleted

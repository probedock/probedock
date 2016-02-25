@api @users
Feature: Various user filters

  A user from an organization should be able to retrieve the users filtered by:
    - Technical

  and sorted by:
    - Creation date (oldest to newest)


  Background:
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user tech1 who is a technical user of Rebel Alliance exists since 1 day ago
    And user tech2 who is a technical user of Rebel Alliance exists since 1 week ago




  Scenario: An organization member should be able to get users of a private organization filtered by technical.
    When hsolo sends a GET request to /api/users?organizationId={@idOf: Rebel Alliance}&technical=true
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: tech1}",
        "name": "tech1",
        "technical": true,
        "organizationId": "{@idOf: Rebel Alliance}",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "{@idOf: tech2}",
        "name": "tech2",
        "technical": true,
        "organizationId": "{@idOf: Rebel Alliance}",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get users of a private organization filtered by technical.
    When hsolo sends a GET request to /api/users?organizationId={@idOf: Rebel Alliance}&technical=true&sort=createdAt
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: tech2}",
        "name": "tech2",
        "technical": true,
        "organizationId": "{@idOf: Rebel Alliance}",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "{@idOf: tech1}",
        "name": "tech1",
        "technical": true,
        "organizationId": "{@idOf: Rebel Alliance}",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted
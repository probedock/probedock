@api @test
Feature: Test

  Users should be able to retrieve the test details by its id.

  The details of a test contains:
  - name
  - category
  - tags
  - key
  - project (object)
  - author/contributors
  - number of results
  - first run date
  - last run date
  - latest project version
  - passing (last result)
  - active/inactive



  Scenario: An organization member should be able to get the test details without project data in his organization
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2 for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Ion engine should provide thrust",
        "name": "Ion engine should provide thrust",
        "category": "C1",
        "key": "k1",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "1.0.0",
        "passing": true,
        "active": true,
        "tags": [ "tag1", "tag2" ],
        "tickets": [ "ticket1", "ticket2" ],
        "contributions": [{
          "userId": "@idOf: lskywalker",
          "kind": "key_creator"
        }]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the test details without project data in his organization with the project id
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Ion engine should provide thrust",
        "name": "Ion engine should provide thrust",
        "category": "C1",
        "key": "k1",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "1.0.0",
        "passing": true,
        "active": true,
        "tags": [ "tag1", "tag2" ],
        "tickets": [ "ticket1", "ticket2" ],
        "contributions": [{
          "userId": "@idOf: lskywalker",
          "kind": "key_creator"
        }]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the test details with project data in his organization
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}&withProject=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Ion engine should provide thrust",
        "name": "Ion engine should provide thrust",
        "category": "C1",
        "key": "k1",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "1.0.0",
        "passing": true,
        "active": true,
        "tags": [ "tag1", "tag2" ],
        "tickets": [ "ticket1", "ticket2" ],
        "contributions": [{
          "userId": "@idOf: lskywalker",
          "kind": "key_creator"
        }],
        "project": {
          "id": "@idOf: X-Wing",
          "name": "@valueOf(X-Wing, name)",
          "displayName": "@valueOf(X-Wing, display_name)",
          "organizationId": "@idOf: Rebel Alliance",
          "testsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should be able to get the test details without project data in a public organization
    Given public organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
    And public organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    When palpatine sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Ion engine should provide thrust",
        "name": "Ion engine should provide thrust",
        "category": "C1",
        "key": "k1",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "1.0.0",
        "passing": true,
        "active": true,
        "tags": [ "tag1", "tag2" ],
        "tickets": [ "ticket1", "ticket2" ],
        "contributions": [{
          "userId": "@idOf: lskywalker",
          "kind": "key_creator"
        }]
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should be able to get the test details without project data in a public organization
    Given public organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
    When nobody sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Ion engine should provide thrust",
        "name": "Ion engine should provide thrust",
        "category": "C1",
        "key": "k1",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "1.0.0",
        "passing": true,
        "active": true,
        "tags": [ "tag1", "tag2" ],
        "tickets": [ "ticket1", "ticket2" ],
        "contributions": [{
          "userId": "@idOf: lskywalker",
          "kind": "key_creator"
        }]
      }
      """
    And nothing should have been added or deleted



   @authorization
   Scenario: A user should not be able to get the test details without project data of a private organization
     Given private organization Rebel Alliance exists
     And user hsolo who is a member of Rebel Alliance exists
     And user lskywalker who is a member of Rebel Alliance exists
     And user wantilles who is a member of Rebel Alliance exists
     And project X-Wing exists within organization Rebel Alliance
     And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
     And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
     And public organization Galactic Empire exists
     And user palpatine who is a member of Galactic Empire exists
     When palpatine sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}
     Then the response code should be 403
     And nothing should have been added or deleted



   @authorization
   Scenario: An anonymous user should not be able to get the test details without project data of a private organization
     Given private organization Rebel Alliance exists
     And user hsolo who is a member of Rebel Alliance exists
     And user lskywalker who is a member of Rebel Alliance exists
     And user wantilles who is a member of Rebel Alliance exists
     And project X-Wing exists within organization Rebel Alliance
     And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
     And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2  for version 1.0.0
     When nobody sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?organizationId={@idOf: Rebel Alliance}
     Then the response code should be 403
     And nothing should have been added or deleted




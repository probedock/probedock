@api @test
Feature: Test

  Users should be able to retrieve test details by its id.

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


  Background:
    # Create organizations
    Given private organization Rebel Alliance exists
    And public organization Galactic Empire exists

    # Create users
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And user palpatine who is a member of Galactic Empire exists

    # Create projects and versions
    And project X-Wing exists within organization Rebel Alliance with repo url https://github.com/probedock/probedock
    And project version 1.0.0 exists for project X-Wing
    And project Star Destroyer exists within organization Galactic Empire
    And project version 2.0.0 exists for project Star Destroyer

    # Create tests
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 and tags tag1, tag2 and tickets ticket1, ticket2 for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    And test "Shields must be powered" was created by palpatine with key k2 for version 2.0.0 of project Star Destroyer

    # Create a result for each test with the report and payload for X-Wing project
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.0.0 of project X-Wing was used to generate report A with context:
      """
      {
        "scm.name": "Git",
        "scm.version": "2.7.1",
        "scm.dirty": true,
        "scm.branch": "star-fighter",
        "scm.commit": "abcdef",
        "scm.remote.name": "origin",
        "scm.remote.url.fetch": "https://github.com/probedock/probedock",
        "scm.remote.url.push": "https://github.com/probedock/probedock",
        "scm.remote.ahead": 1,
        "scm.remote.behind": 2
      }
      """
    And result R1 for test "Ion engine should provide thrust" is new and passing and was run by hsolo and took 20 seconds to run for payload A1 with version 1.0.0 and custom values:
      """
      {
        "file.path": "somewhere/on/file/system.js",
        "file.line": 12
      }
      """
    And result R2 for test "Blasters should fire" is new and passing and was run by hsolo for payload A1 with version 1.0.0

    # Create a result for each test with the report and payload for Star Destroyer project
    And test result report B was generated for organization Galactic Empire
    And test payload B1 sent by palpatine for version 2.0.0 of project Star Destroyer was used to generate report B
    And result R3 for test "Shields must be powered" is new and passing and was run by palpatine and took 200 seconds to run for payload B1 with version 2.0.0



  Scenario: An organization member should be able to get test details in his organization
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}
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
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get test details in his organization with the project id
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}
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
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get test details with project data in his organization
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?withProject=1
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
        "project": {
          "id": "@idOf: X-Wing",
          "name": "@valueOf(X-Wing, name)",
          "displayName": "@valueOf(X-Wing, display_name)",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock",
          "testsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get test details with project and contributions data in his organization
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?&withProject=1&withContributions=1
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
          "user": {
            "id": "@idOf: lskywalker",
            "name": "lskywalker",
            "technical": false,
            "primaryEmailMd5": "@md5OfJson(/contributions/0/user/primaryEmail)",
            "primaryEmail": "@email",
            "emails": [{
                "address": "@json(/contributions/0/user/primaryEmail)",
                "active": false
            }],
            "active": true,
            "roles": [],
            "createdAt": "@iso8601"
          },
          "kind": "key_creator"
        }],
        "project": {
          "id": "@idOf: X-Wing",
          "name": "@valueOf(X-Wing, name)",
          "displayName": "@valueOf(X-Wing, display_name)",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock",
          "testsCount": 0,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        },
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get test details in his organization with scm data
    When hsolo sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}?withScm=true
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
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "star-fighter",
          "commit": "abcdef",
          "dirty": true,
          "remote": {
            "name": "origin",
            "ahead": 1,
            "behind": 2,
            "url": {
              "fetch": "https://github.com/probedock/probedock",
              "push": "https://github.com/probedock/probedock"
            }
          }
        }
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should be able to get test details in a public organization
    When hsolo sends a GET request to /api/tests/{@idOf: Shields must be powered}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Shields must be powered",
        "name": "Shields must be powered",
        "key": "k2",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "2.0.0",
        "passing": true,
        "active": true,
        "tags": [],
        "tickets": []
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should be able to get test details in a public organization
    When nobody sends a GET request to /api/tests/{@idOf: Shields must be powered}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: Shields must be powered",
        "name": "Shields must be powered",
        "key": "k2",
        "resultsCount": 0,
        "firstRunAt": "@iso8601",
        "lastRunAt": "@iso8601",
        "projectVersion": "2.0.0",
        "passing": true,
        "active": true,
        "tags": [],
        "tickets": []
      }
      """
    And nothing should have been added or deleted



   @authorization
   Scenario: A user should not be able to get test details of a private organization
     When palpatine sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}
     Then the response code should be 403
     And nothing should have been added or deleted



   @authorization
   Scenario: An anonymous user should not be able to get test details of a private organization
     When nobody sends a GET request to /api/tests/{@idOf: Ion engine should provide thrust}
     Then the response code should be 403
     And nothing should have been added or deleted




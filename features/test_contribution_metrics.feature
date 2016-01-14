@api @metrics
Feature: Test contribution metrics

  Users should be able to list the contributors of an organization or project.
  Contributors are the users that have written new tests. Users that have not written
  any tests are not included in the list.

  The following additional information should also be provided for each contributor:
  - number of tests written
  - categories of the tests



  Scenario: An organization member should be able to get the organization's contribution metrics
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And user kfarlander who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    And test "Inertial dampeners should work" was first run by wantilles for version 1.2.0 of project X-Wing
    And test "Inertial dampeners should work" has category C2 for version 1.2.0
    And project Y-Wing exists within organization Rebel Alliance
    And test "Photon torpedoes should be accurate" was first run by kfarlander for version 2.1.0 of project Y-Wing
    And test "Photon torpedoes should be accurate" has category C3 for version 2.1.0
    And test "Photon torpedoes should be accurate" has category C4 for version 2.2.0
    And test "Shields should work" was created by wantilles with key k2 for version 2.2.0 of project Y-Wing
    And test "Shields should work" has category C1 for version 2.2.0
    And private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    And project TIE Fighter exists within organization Galactic Empire
    And test "Shield should be absent" was first run by palpatine for version 0.4.5 of project TIE Fighter
    And test "Shield should be absent" has category C4 for version 0.4.5
    And public organization New Jedi Order exists
    And user lskywalker is also a member of New Jedi Order
    And project Lightsaber exists within organization New Jedi Order
    And test "It should cut" was first run by lskywalker for version 0.0.0 of project Lightsaber
    And test "It should cut" has category C5 for version 0.0.0
    When hsolo sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "userId": "@idOf: lskywalker",
          "testsCount": 2,
          "categories": [ "C1", "C2" ]
        },
        {
          "userId": "@idOf: wantilles",
          "testsCount": 2,
          "categories": [ "C1", "C2" ]
        },
        {
          "userId": "@idOf: kfarlander",
          "testsCount": 1,
          "categories": [ "C3" ]
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get a project's contribution metrics
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And user kfarlander who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by lskywalker with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 for version 1.0.0
    And test "Blasters should fire" was first run by lskywalker for version 1.0.0 of project X-Wing
    And test "Blasters should fire" has category C2 for version 1.0.0
    And test "Inertial dampeners should work" was first run by wantilles for version 1.2.0 of project X-Wing
    And test "Inertial dampeners should work" has category C2 for version 1.2.0
    And project Y-Wing exists within organization Rebel Alliance
    And test "Photon torpedoes should be accurate" was first run by kfarlander for version 2.1.0 of project Y-Wing
    And test "Photon torpedoes should be accurate" has category C3 for version 2.1.0
    And test "Photon torpedoes should be accurate" has category C4 for version 2.2.0
    And test "Shields should work" was created by wantilles with key k2 for version 2.2.0 of project Y-Wing
    And test "Shields should work" has category C1 for version 2.2.0
    And private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    And project TIE Fighter exists within organization Galactic Empire
    And test "Shield should be absent" was first run by palpatine for version 0.4.5 of project TIE Fighter
    And test "Shield should be absent" has category C4 for version 0.4.5
    And public organization New Jedi Order exists
    And user lskywalker is also a member of New Jedi Order
    And project Lightsaber exists within organization New Jedi Order
    And test "It should cut" was first run by lskywalker for version 0.0.0 of project Lightsaber
    And test "It should cut" has category C5 for version 0.0.0
    When hsolo sends a GET request to /api/metrics/contributions?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "userId": "@idOf: lskywalker",
          "testsCount": 2,
          "categories": [ "C1", "C2" ]
        },
        {
          "userId": "@idOf: wantilles",
          "testsCount": 1,
          "categories": [ "C2" ]
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: Organization contribution metrics should be empty by default
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When hsolo sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      []
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should be able to get a public organization's contribution metrics
    Given public organization Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by wantilles with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 for version 1.0.0
    When nobody sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "userId": "@idOf: wantilles",
          "testsCount": 1,
          "categories": [ "C1" ]
        }
      ]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should be able to retrieve user details with contribution metrics
    Given public organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test "Ion engine should provide thrust" was created by wantilles with key k1 for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" has category C1 for version 1.0.0
    When hsolo sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}&withUser=1
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "userId": "@idOf: wantilles",
          "testsCount": 1,
          "categories": [ "C1" ],
          "user": {
            "id": "@idOf: wantilles",
            "name": "wantilles",
            "technical": false,
            "primaryEmailMd5": "@md5OfJson(/0/user/primaryEmail)",
            "primaryEmail": "@email",
            "emails": [
              {
                "address": "@json(/0/user/primaryEmail)",
                "active": false
              }
            ],
            "active": true,
            "roles": [],
            "createdAt": "@iso8601"
          }
        }
      ]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get a private organization's contribution metrics
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When nobody sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the contribution metrics for a private organization's project
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When nobody sends a GET request to /api/metrics/contributions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member from another organization should not be able to get a private organization's contribution metrics
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/contributions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the contribution metrics for a private organization's project
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And private organization Galactic Republic exists
    And user dvader who is a member of Galactic Republic exists
    When dvader sends a GET request to /api/metrics/contributions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

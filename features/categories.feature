@api @categories
Feature: Categories list

  Users should be able to list the test categories used within an organization,
  along with the number of tests using each category. The results should be ordered
  by descending number of tests, then by category name.



  Background:
    Given public organization Rebel Alliance exists
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
    And category C5 exists within organization Rebel Alliance
    And private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists
    And project TIE Fighter exists within organization Galactic Empire
    And test "Shield should be absent" was first run by palpatine for version 0.4.5 of project TIE Fighter
    And test "Shield should be absent" has category C4 for version 0.4.5
    And test "Laser cannon should be reasonably accurate" was first run by palpatine for version 0.4.5 of project TIE Fighter
    And test "Laser cannon should be reasonably accurate" has category C5 for version 0.4.5
    And public organization Commerce Guild exists



  Scenario: An anonymous user should be able to list the categories of a public organization
    When nobody sends a GET request to /api/categories?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 200 with the following JSON:
      """
      [
        {
          "name": "C1",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C2",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C3",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C4",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to list the categories of a public organization
    When lskywalker sends a GET request to /api/categories?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 200 with the following JSON:
      """
      [
        {
          "name": "C1",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C2",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C3",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C4",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to list the categories of a private organization
    When palpatine sends a GET request to /api/categories?organizationId={@idOf: Galactic Empire}
    Then the response should be HTTP 200 with the following JSON:
      """
      [
        {
          "name": "C4",
          "testsCount": 1,
          "organizationId": "@idOf: Galactic Empire",
          "createdAt": "@iso8601"
        },
        {
          "name": "C5",
          "testsCount": 1,
          "organizationId": "@idOf: Galactic Empire",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: A Probe Dock administrator should be able to list the categories of all organizations
    Given user yoda who is a Probe Dock admin exists
    When yoda sends a GET request to /api/categories
    Then the response should be HTTP 200 with the following JSON:
      """
      [
        {
          "name": "C4",
          "testsCount": 1,
          "organizationId": "@idOf: Galactic Empire",
          "createdAt": "@iso8601"
        },
        {
          "name": "C5",
          "testsCount": 1,
          "organizationId": "@idOf: Galactic Empire",
          "createdAt": "@iso8601"
        },
        {
          "name": "C1",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C2",
          "testsCount": 2,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C3",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        },
        {
          "name": "C4",
          "testsCount": 1,
          "organizationId": "@idOf: Rebel Alliance",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to see that there are no categories in a public organization
    When nobody sends a GET request to /api/categories?organizationId={@idOf: Commerce Guild}
    Then the response should be HTTP 200 with the following JSON:
      """
      []
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to list the categories of a private organization
    When nobody sends a GET request to /api/categories?organizationId={@idOf: Galactic Empire}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to list the categories of another private organization
    When lskywalker sends a GET request to /api/categories?organizationId={@idOf: Galactic Empire}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to list the categories of all organizations
    When nobody sends a GET request to /api/categories
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to list the categories of all organizations
    When lskywalker sends a GET request to /api/categories
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

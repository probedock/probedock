@api @metrics
Feature: Project health metrics

  Users should be able to retrieve project health metrics

  The following result is provided:
  - testsCount for the total of tests in this version
  - passedTestsCount for the total of passed tests
  - inactiveTestsCount for the total of inactive tests
  - inactivePassedTestsCount for the number of passed tests that are inactive
  - projectVersion id and name



  Background:
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.0.0 exists for project X-Wing with creation date set 5 days ago
    And project version 1.0.1 exists for project X-Wing with creation date set 2 days ago
    And test "Ion engine should provide thrust" was created by hsolo with key aaaa for version 1.0.0 of project X-Wing
    And test "Blasters should fire" was created by hsolo with key bbbb for version 1.0.0 of project X-Wing
    And test "Shields should protect" was created by hsolo with key cccc for version 1.0.0 of project X-Wing
    And test "Boosters should not explode" was created by hsolo with key dddd for version 1.0.0 of project X-Wing
    And test "Ion engine should provide thrust" is passing and active was last run by hsolo and has category C1 for version 1.0.0
    And test "Blasters should fire" is passing and inactive was last run by hsolo and has category C1 for version 1.0.0
    And test "Shields should protect" is failing and active was last run by hsolo and has category C1 for version 1.0.0
    And test "Boosters should not explode" is failing and inactive was last run by hsolo and has category C1 for version 1.0.0
    And test "Ion engine should provide thrust" is passing and active was last run by hsolo and has category C1 for version 1.0.1
    And test "Blasters should fire" is passing and inactive was last run by hsolo and has category C1 for version 1.0.1



  Scenario: An organization member should be able to get the latest project version health
    When hsolo sends a GET request to /api/metrics/projectHealth?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "testsCount": 2,
        "passedTestsCount": 2,
        "inactiveTestsCount": 1,
        "inactivePassedTestsCount": 1,
        "projectVersion": {
          "id": "@idOf: 1.0.1",
          "name": "1.0.1"
        }
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the specific project version health
    When hsolo sends a GET request to /api/metrics/projectHealth?projectVersionId={@idOf: 1.0.0}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "testsCount": 4,
        "passedTestsCount": 2,
        "inactiveTestsCount": 2,
        "inactivePassedTestsCount": 1,
        "projectVersion": {
          "id": "@idOf: 1.0.0",
          "name": "1.0.0"
        }
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the latest project version health from a private organization
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/projectHealth?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the specific project version health from a private organization
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/projectHealth?projectVersionId={@idOf: 1.0.0}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the latest project version health from a private organization
    When nobody sends a GET request to /api/metrics/reportsByDay?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the specific project version health from a private organization
    When nobody sends a GET request to /api/metrics/reportsByDay?projectVersionId{@idOf: 1.0.0}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
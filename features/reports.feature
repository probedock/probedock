@api @reports
Feature: Reports

  After publishing test results to Probe Dock within an organization, users of that
  organization should be able to access to generated test reports.



  Scenario: An organization member should be able to get a report of a private organization by ID
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.2.3 exists for project X-Wing
    And user hsolo who is a member of Rebel Alliance exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    When hsolo sends a GET request to /api/reports/{@idOf: A}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: A",
        "duration": "@valueOf(A1, duration)",
        "resultsCount": 0,
        "passedResultsCount": 0,
        "inactiveResultsCount": 0,
        "inactivePassedResultsCount": 0,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "@idOf: Rebel Alliance",
        "projects": [
          {
            "id": "@idOf: X-Wing",
            "name": "x-wing",
            "displayName": "X-Wing",
            "organizationId": "@idOf: Rebel Alliance"
          }
        ],
        "projectVersions": [
          {
            "id": "@idOf: 1.2.3",
            "name": "1.2.3",
            "projectId": "@idOf: X-Wing",
            "createdAt": "@iso8601"
          }
        ],
        "runners": [
          {
            "id": "@idOf: hsolo",
            "name": "hsolo",
            "technical": false,
            "primaryEmailMd5": "@md5OfJson(/runners/0/primaryEmail)",
            "primaryEmail": "@email"
          }
        ],
        "categories": [],
        "tags": [],
        "tickets": []
      }
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get a report of a public organization by ID
    Given public organization Galactic Republic exists
    And project Star Destroyer exists within organization Galactic Republic
    And project version 1.2.3 exists for project Star Destroyer
    And user palpatine who is a member of Galactic Republic exists
    And test result report A was generated for organization Galactic Republic
    And test payload A1 sent by palpatine for version 1.2.3 of project Star Destroyer was used to generate report A
    When nobody sends a GET request to /api/reports/{@idOf: A}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: A",
        "duration": "@valueOf(A1, duration)",
        "resultsCount": 0,
        "passedResultsCount": 0,
        "inactiveResultsCount": 0,
        "inactivePassedResultsCount": 0,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "@idOf: Galactic Republic",
        "projects": [
          {
            "id": "@idOf: Star Destroyer",
            "name": "star-destroyer",
            "displayName": "Star Destroyer",
            "organizationId": "@idOf: Galactic Republic"
          }
        ],
        "projectVersions": [
          {
            "id": "@idOf: 1.2.3",
            "name": "1.2.3",
            "projectId": "@idOf: Star Destroyer",
            "createdAt": "@iso8601"
          }
        ],
        "runners": [
          {
            "id": "@idOf: palpatine",
            "name": "palpatine",
            "technical": false,
            "primaryEmailMd5": "@string"
          }
        ],
        "categories": [],
        "tags": [],
        "tickets": []
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get a report of a private organization by ID
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test result report A was generated for organization Rebel Alliance
    When nobody sends a GET request to /api/reports/{@idOf: A}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get a report of a private organization by ID
    Given private organization Rebel Alliance exists
    And public organization Galactic Republic exists
    And project X-Wing exists within organization Rebel Alliance
    And user hsolo who is a member of Rebel Alliance exists
    And user palpatine who is a member of Galactic Republic exists
    And test result report A was generated for organization Rebel Alliance
    When palpatine sends a GET request to /api/reports/{@idOf: A}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

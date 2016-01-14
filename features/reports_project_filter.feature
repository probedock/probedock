@api @reports
Feature: Reports

  After publishing test results to Probe Dock for different projects within an organization, users of that
  organization should be able to access a list of reports for a specific project.


  @search
  Scenario: An organization member should be able to get a list of reports for a specific project and a private organization.
    Given private organization Rebel Alliance exists
    And private organization Galactic Empire exists
    And project X-Wing exists within organization Rebel Alliance
    And project Y-Wing exists within organization Rebel Alliance
    And project TIE Fighter exists within organization Galactic Empire
    And user hsolo who is a member of Rebel Alliance exists
    And user palpatine who is a member of Galactic Empire exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    And test result report B was generated for organization Rebel Alliance
    And test payload B1 sent by hsolo for version 4.5.6 of project Y-Wing was used to generate report B
    And test result report C was generated for organization Rebel Alliance
    And test payload C1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report C
    And test result report D was generated for organization Galactic Empire
    And test payload D1 sent by palpatine for version 1.2.3 of project TIE Fighter was used to generate report D
    When hsolo sends a GET request to /api/reports?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: C",
          "duration": "@valueOf(C1, duration)",
          "resultsCount": 0,
          "passedResultsCount": 0,
          "inactiveResultsCount": 0,
          "inactivePassedResultsCount": 0,
          "newTestsCount": 0,
          "startedAt": "@iso8601",
          "endedAt": "@iso8601",
          "createdAt": "@iso8601",
          "organizationId": "@idOf: Rebel Alliance"
        },
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
          "organizationId": "@idOf: Rebel Alliance"
        }
      ]
      """
    And nothing should have been added or deleted



  @search
  Scenario: A member in a different organization should be able to get a list of reports for a specific project from a public organization.
    Given public organization Rebel Alliance exists
    And private organization Galactic Empire exists
    And project X-Wing exists within organization Rebel Alliance
    And project TIE Fighter exists within organization Galactic Empire
    And user hsolo who is a member of Rebel Alliance exists
    And user palpatine who is a member of Galactic Empire exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    And test result report C was generated for organization Rebel Alliance
    And test payload C1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report C
    And test result report D was generated for organization Galactic Empire
    And test payload D1 sent by palpatine for version 1.2.3 of project TIE Fighter was used to generate report D
    When palpatine sends a GET request to /api/reports?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: C",
          "duration": "@valueOf(C1, duration)",
          "resultsCount": 0,
          "passedResultsCount": 0,
          "inactiveResultsCount": 0,
          "inactivePassedResultsCount": 0,
          "newTestsCount": 0,
          "startedAt": "@iso8601",
          "endedAt": "@iso8601",
          "createdAt": "@iso8601",
          "organizationId": "@idOf: Rebel Alliance"
        },
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
          "organizationId": "@idOf: Rebel Alliance"
        }
      ]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An anonymous user should be able to get a list of reports for a specific project from a public organization.
    Given public organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And user hsolo who is a member of Rebel Alliance exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    And test result report C was generated for organization Rebel Alliance
    And test payload C1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report C
    When nobody sends a GET request to /api/reports?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: C",
          "duration": "@valueOf(C1, duration)",
          "resultsCount": 0,
          "passedResultsCount": 0,
          "inactiveResultsCount": 0,
          "inactivePassedResultsCount": 0,
          "newTestsCount": 0,
          "startedAt": "@iso8601",
          "endedAt": "@iso8601",
          "createdAt": "@iso8601",
          "organizationId": "@idOf: Rebel Alliance"
        },
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
          "organizationId": "@idOf: Rebel Alliance"
        }
      ]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get a list report with a project id of a private organization.
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And project Y-Wing exists within organization Rebel Alliance
    And user hsolo who is a member of Rebel Alliance exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    When nobody sends a GET request to /api/reports?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get a list report with a project id of a private organization.
    Given private organization Rebel Alliance exists
    And private organization Galactic Empire exists
    And project X-Wing exists within organization Rebel Alliance
    And project Y-Wing exists within organization Rebel Alliance
    And project TIE Fighter exists within organization Galactic Empire
    And user hsolo who is a member of Rebel Alliance exists
    And user palpatine who is a member of Galactic Empire exists
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    When palpatine sends a GET request to /api/reports?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

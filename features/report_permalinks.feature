@api @reports
Feature: Reports search

  When submitting test result payloads to Probe Dock, integrators want to be able to send an e-mail
  to their organization's users with a link to the generated test report. To enable this, the reports
  API resource must provide filters to find the relevant report(s).

  The following filters are provided to find reports:
  - find a report by its user-defined UID
  - find a report by the ID of a test result payload



  Scenario: An organization member should be able to find a private report with its UID.
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And user hsolo who is a member of Rebel Alliance exists
    And test result report A was generated with UID foo for organization Rebel Alliance
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&uid=foo
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: A",
          "uid": "foo",
          "duration": 0,
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



  Scenario: An organization member should be able to find a private report by the ID of one of its payloads.
    Given private organization Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And user hsolo who is a member of Rebel Alliance exists
    And test result report A was generated with UID foo for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&payloadId={@idOf: A1}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: A",
          "uid": "foo",
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

@api @metrics
Feature: Retrieve the versions for a test where there is no results

  This will allow identifying tests that are not executed for some versions.


  Background:
    # Create private organization with 2 users
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists

    # Create public organization with 2 users
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists

    # Create 1 project with 2 versions
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.2.2 exists for project X-Wing
    And project version 1.2.3 exists for project X-Wing

    # Create 1 report with 1 payload
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.2 of project X-Wing was used to generate report A

    # Create 1 test in 1 version
    And test "Engine should be powered" was created 2 days ago by hsolo with key esbp for version 1.2.2 of project X-Wing

    # Create test results for the test
    And result R1 for test "Engine should be powered" was run by hsolo for payload A1 with version 1.2.2

    # Create 1 project with 2 versions in second organization
    And project Senate exists within organization Old Republic
    And project version 2.0 exists for project Senate
    And project version 2.1 exists for project Senate

    # Create 1 report with 1 payload for Senate project
    And test result report B was generated for organization Old Republic
    And test payload B1 sent by borgana for version 2.0 of project Senate was used to generate report B

    # Create 1 test in 1 version
    And test "Senate should be big enough" was created 2 days ago by borgana with key ssbbe for version 2.0 of project Senate

    # Create test results for the test
    And result R2 for test "Senate should be big enough" was run by borgana for payload B1 with version 2.0



  Scenario: An organization member should be able to get versions with no result for a test in his organization
    When hsolo sends a GET request to /api/metrics/versionsWithNoResult?organizationId={@idOf: Rebel Alliance}&testId={@idOf: Engine should be powered}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 1.2.3",
        "name": "1.2.3",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from different organization should be able to get versions with no result for a test in a public organization
    When hsolo sends a GET request to /api/metrics/versionsWithNoResult?organizationId={@idOf: Old Republic}&testId={@idOf: Senate should be big enough}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 2.1",
        "name": "2.1",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous usershould be able to get versions with no result for a test in a public organization
    When nobody sends a GET request to /api/metrics/versionsWithNoResult?organizationId={@idOf: Old Republic}&testId={@idOf: Senate should be big enough}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 2.1",
        "name": "2.1",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get versions with no results from a private organization
    When nobody sends a GET request to /api/metrics/versionsWithNoResult?organizationId={@idOf: Rebel Alliance}&testId={@idOf: Senate should be big enough}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member from another organization should not be able to get versions with no results from a private organization
    When borgana sends a GET request to /api/metrics/versionsWithNoResult?organizationId={@idOf: Rebel Alliance}&testId={@idOf: Senate should be big enough}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

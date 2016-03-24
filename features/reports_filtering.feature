@api @reports
Feature: Various filters to get reports

  A user from an organization should be able to retrieve the reports filtered by:
    - Projects
    - Project versions
    - Runners
    - Categories
    - Project



  Background:
    # Public orga
    Given public organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists

    # Private orga
    Given private organization Galactic Empire exists
    And user palpatine who is a member of Galactic Empire exists

    # 2 projects
    And project X-Wing exists within organization Rebel Alliance
    And project Y-Wing exists within organization Rebel Alliance

    # 1 project
    And project Star Destroyer exists within organization Galactic Empire

    # 2 versions
    And project version 1.2.3 exists for project X-Wing
    And project version 3.2.1 exists for project X-Wing
    And project version 1.0.0 exists for project Y-Wing

    # 2 tests
    And test "Engine should be powered" was created by hsolo with key aaaa for version 1.2.3 of project X-Wing
    And test "Shields must resist to lasers" was created by hsolo with key bbbb for version 1.2.3 of project Y-Wing

    # For filter by runner
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by lskywalker for version 1.2.3 of project X-Wing was used to generate report A

    # For filter by project
    And test result report B was generated for organization Rebel Alliance
    And test payload B1 sent by hsolo for version 1.0.0 of project Y-Wing was used to generate report B

    # For filter by project version
    And test result report C was generated for organization Rebel Alliance
    And test payload C1 sent by hsolo for version 3.2.1 of project X-Wing was used to generate report C

    # For filter by category
    And test result report D was generated for organization Rebel Alliance
    And test payload D1 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report D

    # Results for filtering
    And result R1 for test "Engine should be powered" is new and passing and was run by lskywalker and took 20 seconds to run for payload A1 with version 1.2.3
    And result R2 for test "Shields must resist to lasers" is new and passing and was run by hsolo and took 20 seconds to run for payload B1 with version 1.0.0
    And result R3 for test "Engine should be powered" is passing and was run by hsolo and took 20 seconds to run for payload C1 with version 3.2.1
    And result R4 for test "Engine should be powered" is passing and has category c1 and was run by hsolo and took 20 seconds to run for payload D1 with version 1.2.3



  @search
  Scenario: An organization member should be able to get reports of a private organization filtered by runners.
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&runnerIds[]={@idOf: lskywalker}
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: A}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An organization member should be able to get reports of a private organization filtered by projects.
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: Y-Wing}
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: B}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An organization member should be able to get reports of a private organization filtered by project versions.
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&projectVersionIds[]={@idOf: 3.2.1}
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: C}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An organization member should be able to get reports of a private organization filtered by project version names.
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&projectVersionNames[]=3.2.1
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: C}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An organization member should be able to get reports of a private organization filtered by category names.
    When hsolo sends a GET request to /api/reports?organizationId={@idOf: Rebel Alliance}&categoryNames[]=c1
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: D}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An organization member should be able to get a list of reports for a specific project and a private organization.
    When hsolo sends a GET request to /api/reports?projectId={@idOf: Y-Wing}
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: B}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: A member in a different organization should be able to get a list of reports for a specific project from a public organization.
    When palpatine sends a GET request to /api/reports?projectId={@idOf: Y-Wing}
    Then the response should be HTTP 200 with the following JSON:
      """
      [{
        "id": "{@idOf: B}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An anonymous user should be able to get a list of reports for a specific project from a public organization.
    When nobody sends a GET request to /api/reports?projectId={@idOf: Y-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "{@idOf: B}",
        "duration": "@integer",
        "resultsCount": 1,
        "passedResultsCount": 1,
        "inactiveResultsCount": 1,
        "inactivePassedResultsCount": 1,
        "newTestsCount": 0,
        "startedAt": "@iso8601",
        "endedAt": "@iso8601",
        "createdAt": "@iso8601",
        "organizationId": "{@idOf: Rebel Alliance}"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get a list report with a project id of a private organization.
    When hsolo sends a GET request to /api/reports?projectId={@idOf: Star Destroyer}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get a list report with a project id of a private organization.
    When nobody sends a GET request to /api/reports?projectId={@idOf: Star Destroyer}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

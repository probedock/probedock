@api @management
Feature: Platform management

  When operating Probe Dock, we want to get some metrics on the database such the size of each table with their indexes.

  There is also the possibility to get few metrics for an organization admin such the number of records
  for the main objects:
    - Payloads
    - Projects
    - Tests
    - Results


  Scenario: A Probe Dock administrator should retrieve the DB stats
    Given user palpatine who is a Probe Dock admin exists
    When palpatine sends a GET request to /api/platformManagement/dbStats
    Then the response code should be 200
    # TODO: Test there is a JSON array with any number of records and test each to have the same structure
    # [{
    #   "name": "@string",
    #   "rowsCount": "@number",
    #   "tableSize": "@number",
    #   "indexesSize": "@number",
    #   "totalSize": "@number"
    # }]
#    And the response body should be the following JSON:


  Scenario: An organization administrator should retrieve the organization stats
    Given public organization Galactic Empire exists
    And user palpatine who is an admin of Galactic Empire exists
    When palpatine sends a GET request to /api/platformManagement/orgStats?organizationId={@idOf: Galactic Empire}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "organizations": [{
          "id": "{@idOf: Galactic Empire}",
          "name": "galactic-empire",
          "displayName": "Galactic Empire",
          "payloadsCount": "@number",
          "projectsCount": "@number",
          "testsCount": "@number",
          "resultsCount": "@number",
          "resultsTrend": [ 0, 0, 0, 0, 0 ]
        }],
        "payloadsCount": "@number",
        "projectsCount": "@number",
        "testsCount": "@number",
        "resultsCount": "@number"
      }
      """


  Scenario: An organization administrator should retrieve the top five organization stats
    Given public organization Galactic Empire exists
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists
    And public organization Rebel Alliance exists
    And user hsolo who is a member of Old Republic exists
    And project Senate exists within organization Old Republic
    And project Millennium Falcon exists within organization Rebel Alliance
    And project version 1.0.0 exists for project Senate
    And project version 2.0.0 exists for project Millennium Falcon
    And test result report A was generated for organization Old Republic
    And test result report B was generated for organization Rebel Alliance
    And test payload A1 sent by borgana for version 1.0.0 of project Senate was used to generate report A
    And test payload B1 sent by hsolo for version 2.0.0 of project Millennium Falcon was used to generate report B
    And test "Should be big enough" was created by borgana with key sbbe for version 1.0.0 of project Senate
    And test "Voting system should have three buttons" was created by borgana with key vsshtb for version 1.0.0 of project Senate
    And test "Should have traps on board" was created by hsolo with key shtob for version 2.0.0 of project Millennium Falcon
    And result R1 for test "Should be big enough" is passing and was run by borgana and took 2 seconds to run for payload A1 with version 1.0.0
    And result R2 for test "Voting system should have three buttons" is failing and was run by borgana and took 6 seconds to run for payload A1 with version 1.0.0
    And result R3 for test "Should have traps on board" is passing and was run by hsolo for payload B1 with version 2.0.0
    And user palpatine who is a Probe Dock admin exists
    When palpatine sends a GET request to /api/platformManagement/orgStats?top=5
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "organizations": [{
          "id": "{@idOf: Old Republic}",
          "name": "old-republic",
          "displayName": "Old Republic",
          "payloadsCount": 1,
          "projectsCount": 1,
          "testsCount": 2,
          "resultsCount": 2,
          "resultsTrend": [ 0, 0, 0, 0, 0 ]
        }, {
          "id": "{@idOf: Rebel Alliance}",
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "payloadsCount": 1,
          "projectsCount": 1,
          "testsCount": 1,
          "resultsCount": 1,
          "resultsTrend": [ 0, 0, 0, 0, 0 ]
        }, {
          "id": "{@idOf: Galactic Empire}",
          "name": "galactic-empire",
          "displayName": "Galactic Empire",
          "payloadsCount": 0,
          "projectsCount": 0,
          "testsCount": 0,
          "resultsCount": 0,
          "resultsTrend": [ 0, 0, 0, 0, 0 ]
        }],
        "payloadsCount": "@number",
        "projectsCount": "@number",
        "testsCount": "@number",
        "resultsCount": "@number"
      }
      """


  @authorization
  Scenario: An organization member should not be able to retrieve DB stats
    Given organization Galactic Empire exists
    And user vader who is an admin of Galactic Empire exists
    When vader sends a GET request to /api/platformManagement/dbStats
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to retrieve DB stats
    When nobody sends a GET request to /api/platformManagement/dbStats
    Then the response should be HTTP 401 with the following errors:
      | message             |
      | Missing credentials |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to retrieve org stats in another organization
    Given organization Galactic Empire exists
    And user vader who is an admin of Galactic Empire exists
    And public organization Old Republic exists
    When vader sends a GET request to /api/platformManagement/orgStats?organizationId={@idOf: Old Republic}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to retrieve org stats
    Given organization Galactic Empire exists
    When nobody sends a GET request to /api/platformManagement/orgStats?organizationId={@idOf: Galactic Empire}
    Then the response should be HTTP 401 with the following errors:
      | message             |
      | Missing credentials |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to retrieve top five org stats in another organization
    Given organization Galactic Empire exists
    And user vader who is an admin of Galactic Empire exists
    And public organization Old Republic exists
    When vader sends a GET request to /api/platformManagement/orgStats?top=5
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to retrieve top five org stats
    Given organization Galactic Empire exists
    When nobody sends a GET request to /api/platformManagement/orgStats?top=5
    Then the response should be HTTP 401 with the following errors:
      | message             |
      | Missing credentials |
    And nothing should have been added or deleted

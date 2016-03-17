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
        "organization": {
          "payloadsCount": "@number",
          "projectsCount": "@number",
          "testsCount": "@number",
          "resultsCount": "@number"
        },
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

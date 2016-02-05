@api @metrics
Feature: Tests by categories

  Users should be able to retrieve metrics about the number of tests by category in an organization.

  The metrics can be filtered by project in two different ways:
  - by supplying a project version ID, the metrics will only be computed for the tests existing in that project version
  - by supplying a project list, the metrics will be computed for all tests in the specified projects
    (at the last created version for each project)

  The metrics can also be filtered by a list of users, so that the metrics are only computed for
  tests authored by these specific users.

  The response includes an array of categories. For each category, the following information is provided:
  - the name of the category
  - the number of tests for the category

  Some tests may have no category. The number of tests with no category is available as
  a property on the response object.



  Background:
    # Create first organization with 3 users
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And user wantilles who is a member of Rebel Alliance exists

    # Create first project with 2 versions
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.0.0 exists for project X-Wing since 5 days ago
    And project version 1.0.1 exists for project X-Wing since 2 days ago

    # Create second project with one version
    And project Y-Wing exists within organization Rebel Alliance
    And project version 2.0.0 exists for project Y-Wing

    # Create tests for project X-Wing and version 1.0.0
    And test "Ion engine should provide thrust" was created by hsolo with key aaaa for version 1.0.0 of project X-Wing
    And test "Blasters should fire" was created by lskywalker with key bbbb for version 1.0.0 of project X-Wing
    And test "Shields should protect" was created by hsolo with key cccc for version 1.0.0 of project X-Wing
    And test "Boosters should not explode" was created by lskywalker with key dddd for version 1.0.0 of project X-Wing

    # Run tests for project X-Wing and version 1.0.0 (2 tests for C1, 2 tests without category)
    And test "Ion engine should provide thrust" was last run by hsolo for version 1.0.0
    And test "Blasters should fire" was last run by hsolo for version 1.0.0
    And test "Shields should protect" was last run by hsolo and has category C1 for version 1.0.0
    And test "Boosters should not explode" was last run by hsolo and has category C1 for version 1.0.0

    # Run tests for project X-Wing and version 1.0.1 (1 test for C2, 2 tests for C1, 1 test without category)
    And test "Blasters should fire" was last run by hsolo for version 1.0.1
    And test "Ion engine should provide thrust" was last run by hsolo and has category C1 for version 1.0.1
    And test "Shields should protect" was last run by hsolo and has category C1 for version 1.0.1
    And test "Boosters should not explode" was last run by hsolo and has category C2 for version 1.0.1

    # Create tests for project Y-Wing and version 2.0.0
    And test "Fuel for B-Wing must work on Y-Wing" was created by lskywalker with key eeee for version 2.0.0 of project Y-Wing
    And test "Only two reactors are required" was created by wantilles with key ffff for version 2.0.0 of project Y-Wing

    # Run tests for project Y-Wing and version 2.0.0 (2 tests for C3)
    And test "Fuel for B-Wing must work on Y-Wing" was last run by hsolo and has category C3 for version 2.0.0
    And test "Only two reactors are required" was last run by hsolo and has category C3 for version 2.0.0

    # Create second organization with 2 users
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists
    And user mwindu who is a member of Old Republic exists

    # Create first project with 1 version
    And project Jedi Temple exists within organization Old Republic
    And project version 3.2.1 exists for project Jedi Temple

    # Create second project with 1 version
    And project Senate exists within organization Old Republic
    And project version 6.5.4 exists for project Senate

    # Create tests for project Jedi Temple and version 3.2.1
    And test "Rooms must be available for padawans" was created by mwindu with key gggg for version 3.2.1 of project Jedi Temple
    And test "Lightsabers for training must be safe" was created by mwindu with key hhhh for version 3.2.1 of project Jedi Temple

    # Run tests for project Jedi Temple and version 6.5.4 (1 test for C4, 1 test for C5)
    And test "Rooms must be available for padawans" was last run by borgana and has category C4 for version 3.2.1
    And test "Lightsabers for training must be safe" was last run by borgana and has category C5 for version 3.2.1

    # Create tests for project Senate and version 6.5.4
    And test "Senate chamber must have enough chairs for all delegates" was created by borgana with key iiii for version 6.5.4 of project Senate
    And test "No public access to senate chamber should be enforced" was created by borgana with key jjjj for version 6.5.4 of project Senate

    # Run tests for project Senate and version 6.5.4 (2 tests without category)
    And test "Senate chamber must have enough chairs for all delegates" was last run by mwindu for version 6.5.4
    And test "No public access to senate chamber should be enforced" was last run by borgana for version 6.5.4



  Scenario: An organization member should be able to retrieve the number of tests by categories
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 1,
        "categories": [
          {
            "name": "C1",
            "testsCount": 2
          },
          {
            "name": "C2",
            "testsCount": 1
          },
          {
            "name": "C3",
            "testsCount": 2
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the number of tests by categories filtered by projects
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
       "noCategoryTestsCount": 1,
       "categories": [
         {
           "name": "C1",
           "testsCount": 2
         },
         {
           "name": "C2",
           "testsCount": 1
         }
       ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the number of tests by categories filtered by users
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}&userIds[]={@idOf: lskywalker}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 1,
        "categories": [
          {
            "name": "C2",
            "testsCount": 1
          },
          {
            "name": "C3",
            "testsCount": 1
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the number of tests by categories filtered by projects and users
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: Y-Wing}&userIds[]={@idOf: lskywalker}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 0,
        "categories": [
          {
            "name": "C3",
            "testsCount": 1
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the number of tests by categories filtered by project version
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}&projectVersionId[]={@idOf: 1.0.0}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 2,
        "categories": [
          {
            "name": "C1",
            "testsCount": 2
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the number of tests by categories filtered by project version and users
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Rebel Alliance}&userIds[]={@idOf: lskywalker}&projectVersionId[]={@idOf: 1.0.0}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 1,
        "categories": [
          {
            "name": "C1",
            "testsCount": 1
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to retrieve the number of tests by categories from a public organization
    When hsolo sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 2,
        "categories": [
          {
            "name": "C4",
            "testsCount": 1
          },
          {
            "name": "C5",
            "testsCount": 1
          }
        ]
      }
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to retrieve the number of tests by categories from a public organization
    When nobody sends a GET request to /api/metrics/testsByCategories?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "noCategoryTestsCount": 2,
        "categories": [
          {
            "name": "C4",
            "testsCount": 1
          },
          {
            "name": "C5",
            "testsCount": 1
          }
        ]
      }
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the number of tests by categories from a private organization
    When borgana sends a GET request to /api/metrics/projectHealth?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the number of tests by categories from a private organization
    When nobody sends a GET request to /api/metrics/projectHealth?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted


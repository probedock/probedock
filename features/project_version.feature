@api @project-version
Feature: Project version

  Users should be able to retrieve project versions.

  The details of a project version contains:
  - name
  - project id
  - creation date
  - test id



  Background:
    # Create private organization with 1 user
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists

    # Create first project with 2 versions
    And project X-Wing exists within organization Rebel Alliance
    And project version 1.0.1 exists for project X-Wing since 2 days ago
    And project version 1.0.0 exists for project X-Wing since 1 day ago

    # Create second project with 2 versions
    And project Y-Wing exists within organization Rebel Alliance
    And project version a exists for project Y-Wing since 10 days ago
    And project version b exists for project Y-Wing since 5 days ago
    And project version c exists for project Y-Wing since 3 days ago

    # Create a report with 2 tests with 2 different versions for project X-Wing
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.0.0 of project X-Wing was used to generate report A
    And test "Engines should be powered" was created by hsolo with key esbp for version 1.0.0 of project X-Wing
    And result R1 for test "Engines should be powered" is passing and was run by hsolo for payload A1 with version 1.0.0
    And test "Shields must be active" was created by hsolo with key smba for version 1.0.1 of project X-Wing
    And result R2 for test "Shields must be active" is passing and was run by hsolo for payload A1 with version 1.0.1

    # Create a report with 1 tests for 3 versions for project Y-Wing
    And test result report B was generated for organization Rebel Alliance
    And test payload B1 sent by hsolo for version a of project Y-Wing was used to generate report B
    And test "Bombs must be ready" was created by hsolo with key bmbr for version a of project Y-Wing
    And result R3 for test "Bombs must be ready" is passing and was run by hsolo for payload B1 with version a
    And result R4 for test "Bombs must be ready" is passing and was run by hsolo for payload B1 with version b
    And result R5 for test "Bombs must be ready" is passing and was run by hsolo for payload B1 with version c

    # Create a second organization
    And public organization Old Republic exists
    And user jjbinks who is a member of Old Republic exists

    # Create first project with 2 versions
    And project Jedi Temple exists within organization Old Republic
    And project version 2.0.1 exists for project Jedi Temple since 2 days ago
    And project version 2.0.0 exists for project Jedi Temple since 1 day ago

    # Create second project with 1 version
    And project Senate exists within organization Old Republic
    And project version 3.0.0 exists for project Senate since 3 days ago
    And project version 3.0.1 exists for project Senate since 2 days ago
    And project version 3.0.2 exists for project Senate since 1 day ago
    And project version 3.0.3 exists for project Senate

    # Create a report with 2 tests with 2 different versions for project Jedi Temple
    And test result report C was generated for organization Old Republic
    And test payload C1 sent by jjbinks for version 2.0.0 of project Jedi Temple was used to generate report C
    And test "Dormitory is present" was created by jjbinks with key dip for version 2.0.0 of project Jedi Temple
    And result R6 for test "Dormitory is present" is passing and was run by jjbinks for payload C1 with version 2.0.0
    And test "Training room is available for padawans" was created by jjbinks with key triafp for version 2.0.1 of project Jedi Temple
    And result R7 for test "Training room is available for padawans" is passing and was run by jjbinks for payload C1 with version 2.0.1

    # Create a report with 1 tests for 3 versions for project Senate
    And test result report D was generated for organization Old Republic
    And test payload D1 sent by jjbinks for version 3.0.0 of project Senate was used to generate report D
    And test "Senators can attend meetings" was created by jjbinks with key scam for version 3.0.0 of project Senate
    And result R8 for test "Senators can attend meetings" is passing and was run by jjbinks for payload D1 with version 3.0.0
    And result R9 for test "Senators can attend meetings" is passing and was run by jjbinks for payload D1 with version 3.0.1
    And result R10 for test "Senators can attend meetings" is passing and was run by jjbinks for payload D1 with version 3.0.2
    And result R11 for test "Senators can attend meetings" is passing and was run by jjbinks for payload D1 with version 3.0.3



  Scenario: An organization member should be able to get project versions in his organization
    When hsolo sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 1.0.0",
        "name": "1.0.0",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 1.0.1",
        "name": "1.0.1",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c",
        "name": "c",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: b",
        "name": "b",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: a",
        "name": "a",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get project versions for a specific project
    When hsolo sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 1.0.0",
        "name": "1.0.0",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 1.0.1",
        "name": "1.0.1",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous member should be able to get project versions from a public organization
    When nobody sends a GET request to /api/projectVersions?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 2.0.0",
        "name": "2.0.0",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 2.0.1",
        "name": "2.0.1",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.3",
        "name": "3.0.3",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.2",
        "name": "3.0.2",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.1",
        "name": "3.0.1",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.0",
        "name": "3.0.0",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous member should be able to get project versions for a project in a public organization
    When nobody sends a GET request to /api/projectVersions?projectId={@idOf: Jedi Temple}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 2.0.0",
        "name": "2.0.0",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 2.0.1",
        "name": "2.0.1",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get project versions for a test
    When hsolo sends a GET request to /api/projectVersions?testId={@idOf: Bombs must be ready}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: c",
        "name": "c",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: b",
        "name": "b",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: a",
        "name": "a",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from a different organization should be able to get project versions for a test in a public organization
    When hsolo sends a GET request to /api/projectVersions?testId={@idOf: Dormitory is present}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 2.0.0",
        "name": "2.0.0",
        "projectId": "@idOf: Jedi Temple",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from a different organization should be able to get project versions for a test in a public organization
    When hsolo sends a GET request to /api/projectVersions?testId={@idOf: Senators can attend meetings}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 3.0.3",
        "name": "3.0.3",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.2",
        "name": "3.0.2",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.1",
        "name": "3.0.1",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 3.0.0",
        "name": "3.0.0",
        "projectId": "@idOf: Senate",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get project versions in his organization only sorted by creation date
    And project version 1.0.2 exists for project X-Wing since 6 days ago
    When hsolo sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}&sort=createdAt
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: 1.0.0",
        "name": "1.0.0",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 1.0.1",
        "name": "1.0.1",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c",
        "name": "c",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: b",
        "name": "b",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: 1.0.2",
        "name": "1.0.2",
        "projectId": "@idOf: X-Wing",
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: a",
        "name": "a",
        "projectId": "@idOf: Y-Wing",
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get project versions without specifying the organization
    When hsolo sends a GET request to /api/projectVersions
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get project versions of a private organization
    When jjbinks sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get the versions of a project in a private organization
    When jjbinks sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A user should not be able to get the versions of a project in a private organization by test
    When jjbinks sends a GET request to /api/projectVersions?testId={@idOf: Engines should be powered}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get project versions without specifying the organization
    When nobody sends a GET request to /api/projectVersions
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get project versions of a private organization
    When nobody sends a GET request to /api/projectVersions?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the versions of a project in a private organization
    When nobody sends a GET request to /api/projectVersions?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the versions of a project in a private organization by test
    When nobody sends a GET request to /api/projectVersions?testId={@idOf: Engines should be powered}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

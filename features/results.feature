@api @results
Feature: Results

  After publishing test results to Probe Dock within an organization, users of that
  organization should be able to access to the results in a report.


  Background:
    # Create private organization with 2 users
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists

    # Create public organization with 2 users
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists
    And user pamidala who is a member of Old Republic exists

    # Create 1 project with 2 versions
    And project X-Wing exists within organization Rebel Alliance with repo url https://github.com/probedock/probedock
    And project version 1.2.2 exists for project X-Wing
    And project version 1.2.3 exists for project X-Wing

    # Create 1 report with 2 payloads
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.2.2 of project X-Wing was used to generate report A with context:
      """
      {
        "scm.name": "Git",
        "scm.version": "2.7.1",
        "scm.dirty": true,
        "scm.branch": "star-fighter",
        "scm.commit": "abcdef",
        "scm.remote.name": "origin",
        "scm.remote.url.fetch": "https://github.com/probedock/probedock",
        "scm.remote.url.push": "https://github.com/probedock/probedock",
        "scm.remote.ahead": 1,
        "scm.remote.behind": 2
      }
      """
    And test payload A2 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report A

    # Create 1 report with 1 payload
    And test result report B was generated for organization Rebel Alliance
    And test payload B1 sent by lskywalker for version 1.2.3 of project X-Wing was used to generate report B
    And test payload B2 sent by hsolo for version 1.2.3 of project X-Wing was used to generate report B

    # Create 2 tests in two different versions
    And test "Engine should be powered" was created by hsolo with key aaaa for version 1.2.3 of project X-Wing
    And test "Shields must resist to lasers" was created by hsolo with key bbbb for version 1.2.2 of project X-Wing

    # Create test results for the two tests and same version and the two first payloads
    And result R1 for test "Engine should be powered" is new and passing and was run by hsolo and took 20 seconds to run for payload A1 with version 1.2.2 and custom values:
      """
      {
        "file.path": "somewhere/on/file/system.js",
        "file.line": 12
      }
      """
    And result R2 for test "Shields must resist to lasers" is new and passing and was run by hsolo for payload A2 with version 1.2.3

    # Create a test results for first test and third payload
    And result R6 for test "Engine should be powered" is passing and was run by lskywalker and took 10 seconds to run for payload B1 with version 1.2.3
    And result R8 for test "Engine should be powered" is passing and was run by hsolo and took 8 seconds to run for payload B2 with version 1.2.3

    # Create 1 project for public organization with 2 versions
    And project Senate exists within organization Old Republic
    And project version 1.0.0 exists for project Senate
    And project version 1.0.1 exists for project Senate

    # Create 1 report with 2 payloads
    And test result report C was generated for organization Old Republic
    And test payload C1 sent by borgana for version 1.0.0 of project Senate was used to generate report C
    And test payload C2 sent by borgana for version 1.0.0 of project Senate was used to generate report C

    # Create 1 report with 1 payload
    And test result report D was generated for organization Old Republic
    And test payload D1 sent by borgana for version 1.0.1 of project Senate was used to generate report D

    # Create 2 tests
    And test "Should be big enough" was created by borgana with key sbbe for version 1.0.0 of project Senate
    And test "Voting system should have three buttons" was created by borgana with key vsshtb for version 1.0.0 of project Senate

    # Create test results for the tests
    And result R3 for test "Should be big enough" is passing and was run by borgana and took 2 seconds to run for payload C1 with version 1.0.0
    And result R4 for test "Voting system should have three buttons" is failing and was run by borgana and took 6 seconds to run for payload C1 with version 1.0.0
    And result R5 for test "Voting system should have three buttons" is passing and was run by borgana and took 3 seconds to run for payload C1 with version 1.0.1
    And result R9 for test "Voting system should have three buttons" is passing and was run by pamidala and took 9 seconds to run for payload C2 with version 1.0.1

    # Create a test result for second test and second report
    And result R7 for test "Voting system should have three buttons" is passing and was run by borgana and took 5 seconds to run for payload D1 with version 1.0.1



  Scenario: An organization member should be able to get results of a report in a private organization
    When hsolo sends a GET request to /api/results?reportId={@idOf: A}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      },{
        "id": "@valueOf(R2, id)",
        "name": "Shields must resist to lasers",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 750,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization
    When hsolo sends a GET request to /api/results?reportId={@idOf: C}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization ordered by run at
    When hsolo sends a GET request to /api/results?reportId={@idOf: C}&sort=runAt
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization
    When nobody sends a GET request to /api/results?reportId={@idOf: C}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization by test id
    When hsolo sends a GET request to /api/results?testId={@idOf: Engine should be powered}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }, {
        "id": "@valueOf(R6, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 10,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: lskywalker",
          "name": "lskywalker",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R8, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 8,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization
    When hsolo sends a GET request to /api/results?testId={@idOf: Should be big enough}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization
    When nobody sends a GET request to /api/results?testId={@idOf: Should be big enough}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization by project version
    When hsolo sends a GET request to /api/results?projectVersionId={@idOf: 1.2.2}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report from a public organization by project version
    When hsolo sends a GET request to /api/results?projectVersionId={@idOf: 1.0.0}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report from a public organization by project version
    When nobody sends a GET request to /api/results?projectVersionId={@idOf: 1.0.1}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R7, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 5,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization by project
    When hsolo sends a GET request to /api/results?projectId={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12"
      }, {
        "id": "@valueOf(R6, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 10,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: lskywalker",
          "name": "lskywalker",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R8, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 8,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R2, id)",
        "name": "Shields must resist to lasers",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 750,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report from a public organization by project
    When hsolo sends a GET request to /api/results?projectId={@idOf: Senate}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R7, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 5,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report from a public organization by project
    When nobody sends a GET request to /api/results?projectId={@idOf: Senate}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601"
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }, {
          "id": "@valueOf(R9, id)",
          "name": "Voting system should have three buttons",
          "testId": "@alphanumeric",
          "passed": true,
          "active": true,
          "message": null,
          "duration": 9,
          "newTest": false,
          "tags": [],
          "tickets": [],
          "customData": {},
          "runner": {
            "id": "@idOf: pamidala",
            "name": "pamidala",
            "technical": false,
            "primaryEmailMd5": "@string"
          },
          "project": {
            "id": "@idOf: Senate",
            "name": "senate",
            "displayName": "Senate",
            "organizationId": "@idOf: Old Republic"
          },
          "projectVersion": "1.0.1",
          "runAt": "@iso8601"
        }, {
        "id": "@valueOf(R7, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 5,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization by runners
    When hsolo sends a GET request to /api/results?reportId={@idOf: B}&runnerIds[]={@idOf: lskywalker}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R6, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 10,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: lskywalker",
          "name": "lskywalker",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member of another organization should be able to get results of a report from a public organization by runners
    When hsolo sends a GET request to /api/results?reportId={@idOf: C}&runnerIds[]={@idOf: pamidala}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report from a public organization by runners
    When nobody sends a GET request to /api/results?reportId={@idOf: C}&runnerIds[]={@idOf: pamidala}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization with scm data
    When hsolo sends a GET request to /api/results?reportId={@idOf: A}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/blob/abcdef/somewhere/on/file/system.js#L12",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "star-fighter",
          "commit": "abcdef",
          "dirty": true,
          "remote": {
            "name": "origin",
            "ahead": 1,
            "behind": 2,
            "url": {
              "fetch": "https://github.com/probedock/probedock",
              "push": "https://github.com/probedock/probedock"
            }
          }
        }
      },{
        "id": "@valueOf(R2, id)",
        "name": "Shields must resist to lasers",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 750,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization with scm data
    When hsolo sends a GET request to /api/results?reportId={@idOf: C}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization with scm data
    When nobody sends a GET request to /api/results?reportId={@idOf: C}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization with scm data
    And the project X-Wing updated with the repo url pattern {{repoUrl}}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}
    When hsolo sends a GET request to /api/results?reportId={@idOf: A}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R1, id)",
        "name": "Engine should be powered",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "somewhere/on/file/system.js",
          "file.line": 12
        },
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock",
          "repoUrlPattern": "{{repoUrl}}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}"
        },
        "projectVersion": "1.2.2",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/probedock/star-fighter/abcdef/somewhere/on/file/system.js#L12",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "star-fighter",
          "commit": "abcdef",
          "dirty": true,
          "remote": {
            "name": "origin",
            "ahead": 1,
            "behind": 2,
            "url": {
              "fetch": "https://github.com/probedock/probedock",
              "push": "https://github.com/probedock/probedock"
            }
          }
        }
      },{
        "id": "@valueOf(R2, id)",
        "name": "Shields must resist to lasers",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 750,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: hsolo",
          "name": "hsolo",
          "technical": false,
          "primaryEmailMd5": "@string",
          "primaryEmail": "@email"
        },
        "project": {
          "id": "@idOf: X-Wing",
          "name": "x-wing",
          "displayName": "X-Wing",
          "organizationId": "@idOf: Rebel Alliance",
          "repoUrl": "https://github.com/probedock/probedock",
          "repoUrlPattern": "{{repoUrl}}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}"
        },
        "projectVersion": "1.2.3",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization with scm data
    And the project X-Wing updated with the repo url pattern {{repoUrl}}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}
    When hsolo sends a GET request to /api/results?reportId={@idOf: C}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization with scm data
    And the project X-Wing updated with the repo url pattern {{repoUrl}}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}
    When nobody sends a GET request to /api/results?reportId={@idOf: C}&withScm=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": false,
        "active": true,
        "message": null,
        "duration": 6,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R3, id)",
        "name": "Should be big enough",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 2,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R5, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 3,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }, {
        "id": "@valueOf(R9, id)",
        "name": "Voting system should have three buttons",
        "testId": "@alphanumeric",
        "passed": true,
        "active": true,
        "message": null,
        "duration": 9,
        "newTest": false,
        "tags": [],
        "tickets": [],
        "customData": {},
        "runner": {
          "id": "@idOf: pamidala",
          "name": "pamidala",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic"
        },
        "projectVersion": "1.0.1",
        "runAt": "@iso8601",
        "scm": {}
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get results of a report in a private organization
    When nobody sends a GET request to /api/results?reportId={@idOf: A}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get results of a report in a private organization
    Given public organization Galactic Republic exists
    And user palpatine who is a member of Galactic Republic exists
    When palpatine sends a GET request to /api/results?reportId={@idOf: A}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get results of a report in a private organization by test
    When nobody sends a GET request to /api/results?testId={@idOf: Engine should be powered}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get results of a report in a private organization by test
    Given public organization Galactic Republic exists
    And user palpatine who is a member of Galactic Republic exists
    When palpatine sends a GET request to /api/results?testId={@idOf: Engine should be powered}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get results of a report in a private organization by project
    When nobody sends a GET request to /api/results?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get results of a report in a private organization by project
    Given public organization Galactic Republic exists
    And user palpatine who is a member of Galactic Republic exists
    When palpatine sends a GET request to /api/results?projectId={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get results of a report in a private organization by project version
    When nobody sends a GET request to /api/results?projectVersionId={@idOf: 1.2.3}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: A member of another organization should not be able to get results of a report in a private organization by project version
    Given public organization Galactic Republic exists
    And user palpatine who is a member of Galactic Republic exists
    When palpatine sends a GET request to /api/results?projectVersionId={@idOf: 1.2.3}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
@api @results @scm
Feature: Results with scm data

  After publishing test results to Probe Dock within an organization, users of that
  organization should be able to access to the results in a report.

  The SCM data collected should be present in the results retrieved.



  Background:
    # Create private organization with 2 users
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists

    # Create public organization with 2 users
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists

    # Create 1 project with 2 versions
    And project X-Wing exists within organization Rebel Alliance with repo url https://github.com/probedock/probedock
    And project version 1.0.0 exists for project X-Wing

    # Create 1 report with 2 payloads
    And test result report A was generated for organization Rebel Alliance
    And test payload A1 sent by hsolo for version 1.0.0 of project X-Wing was used to generate report A with context:
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

    # Create 2 tests in two different versions
    And test "Engine should be powered" was created by hsolo with key aaaa for version 1.0.0 of project X-Wing
    And test "Shields must resist to lasers" was created by hsolo with key bbbb for version 1.0.0 of project X-Wing

    # Create test results for the two tests and same version and the two first payloads
    And result R1 for test "Engine should be powered" is new and passing and was run by hsolo and took 20 seconds to run for payload A1 with version 1.0.0 and custom values:
      """
      {
        "file.path": "somewhere/on/file/system.js",
        "file.line": 12
      }
      """
    And result R2 for test "Shields must resist to lasers" is new and passing and was run by hsolo for payload A1 with version 1.0.0

    # Create 1 project for public organization with 2 versions
    And project Senate exists within organization Old Republic with repo url https://github.com/probedock/old-republic
    And project version 2.0.0 exists for project Senate

    # Create 1 report with 2 payloads
    And test result report B was generated for organization Old Republic
    And test payload B1 sent by borgana for version 2.0.0 of project Senate was used to generate report B with context:
      """
      {
        "scm.name": "Git",
        "scm.version": "2.7.1",
        "scm.dirty": false,
        "scm.branch": "senate",
        "scm.commit": "xyzxyz",
        "scm.remote.name": "origin",
        "scm.remote.url.fetch": "https://github.com/probedock/old-republic",
        "scm.remote.url.push": "https://github.com/probedock/old-republic",
        "scm.remote.ahead": 0,
        "scm.remote.behind": 0
      }
      """

    # Create 2 tests
    And test "Should be big enough" was created by borgana with key sbbe for version 2.0.0 of project Senate
    And test "Voting system should have three buttons" was created by borgana with key vsshtb for version 2.0.0 of project Senate

    # Create test results for the two tests and same version and the two first payloads
    And result R3 for test "Should be big enough" is new and passing and was run by borgana and took 20 seconds to run for payload B1 with version 2.0.0 and custom values:
      """
      {
        "file.path": "in/a/galaxy/far/far/away.js",
        "file.line": 1337
      }
      """
    And result R4 for test "Voting system should have three buttons" is new and passing and was run by borgana for payload B1 with version 2.0.0



  Scenario: An organization member should be able to get results of a report in a private organization with scm data.
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
        "projectVersion": "1.0.0",
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
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
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
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization with scm data.
    When hsolo sends a GET request to /api/results?reportId={@idOf: B}&withScm=true
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
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "in/a/galaxy/far/far/away.js",
          "file.line": 1337
        },
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
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/old-republic/blob/xyzxyz/in/a/galaxy/far/far/away.js#L1337",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      },{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
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
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization with scm data.
    When nobody sends a GET request to /api/results?reportId={@idOf: B}&withScm=true
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
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "in/a/galaxy/far/far/away.js",
          "file.line": 1337
        },
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
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/old-republic/blob/xyzxyz/in/a/galaxy/far/far/away.js#L1337",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      },{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
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
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get results of a report in a private organization with scm data.
    And the project X-Wing updated with the repo url pattern {{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}
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
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}"
        },
        "projectVersion": "1.0.0",
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
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}#L{{ fileLine }}"
        },
        "projectVersion": "1.0.0",
        "runAt": "@iso8601",
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
      }]
      """
    And nothing should have been added or deleted



  Scenario: A member from another organization should be able to get results of a report of a public organization with scm data.
    And the project Senate updated with the repo url pattern {{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}
    When hsolo sends a GET request to /api/results?reportId={@idOf: B}&withScm=true
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
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "in/a/galaxy/far/far/away.js",
          "file.line": 1337
        },
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
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic",
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/old-republic/senate/xyzxyz/in/a/galaxy/far/far/away.js",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      },{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
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
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic",
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to get results of a report of a public organization with scm data.
    And the project Senate updated with the repo url pattern {{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}
    When nobody sends a GET request to /api/results?reportId={@idOf: B}&withScm=true
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
        "duration": 20,
        "newTest": true,
        "tags": [],
        "tickets": [],
        "customData": {
          "file.path": "in/a/galaxy/far/far/away.js",
          "file.line": 1337
        },
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
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic",
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "sourceUrl": "https://github.com/probedock/old-republic/senate/xyzxyz/in/a/galaxy/far/far/away.js",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      },{
        "id": "@valueOf(R4, id)",
        "name": "Voting system should have three buttons",
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
          "id": "@idOf: borgana",
          "name": "borgana",
          "technical": false,
          "primaryEmailMd5": "@string"
        },
        "project": {
          "id": "@idOf: Senate",
          "name": "senate",
          "displayName": "Senate",
          "organizationId": "@idOf: Old Republic",
          "repoUrl": "https://github.com/probedock/old-republic",
          "repoUrlPattern": "{{ repoUrl }}/{{ branch }}/{{ commit }}/{{ filePath }}"
        },
        "projectVersion": "2.0.0",
        "runAt": "@iso8601",
        "scm": {
          "name": "Git",
          "version": "2.7.1",
          "branch": "senate",
          "commit": "xyzxyz",
          "dirty": false,
          "remote": {
            "name": "origin",
            "ahead": 0,
            "behind": 0,
            "url": {
              "fetch": "https://github.com/probedock/old-republic",
              "push": "https://github.com/probedock/old-republic"
            }
          }
        }
      }]
      """
    And nothing should have been added or deleted
@api @users
Feature: Users

  Retrieving users with additional informations


  Background:
    Given user master who is a Probe Dock admin exists

    # Create private organization with 2 users
    And private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists with primary email han.solo@localhost.localdomain
    And user lskywalker who is a member of Rebel Alliance exists with primary email luke.skywalker@localhost.localdomain and is inactive

    # Create public organization with 2 users
    And public organization Old Republic exists
    And user borgana who is a member of Old Republic exists with primary email bail.organa@localhost.localdomain
    And user pamidala who is a member of Old Republic exists with primary email padme.amidala@localhost.localdomain
    And user c3po who is a technical user of Old Republic exists

    # Create public organization with 3 users
    And public organization Galactic Empire exists
    And user dvader who is a member of Galactic Empire exists with primary email dark.vader@localhost.localdomain
    And user palpatine who is a member of Galactic Empire exists with primary email palpatine@localhost.localdomain
    And user borgana is also a member of Galactic Empire



  Scenario: An organization member should be able to retrieve all users with only details for his organizations
    When borgana sends a GET request to /api/users
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "bail.organa@localhost.localdomain",
        "emails": [{
          "address": "bail.organa@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: dvader",
        "name": "dvader",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "dark.vader@localhost.localdomain",
        "emails": [{
          "address": "dark.vader@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: master",
        "name": "master",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [
          "admin"
        ],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: palpatine",
        "name": "palpatine",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "palpatine@localhost.localdomain",
        "emails": [{
          "address": "palpatine@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: pamidala",
        "name": "pamidala",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "padme.amidala@localhost.localdomain",
        "emails": [{
          "address": "padme.amidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to retrieve all users without details
    When nobody sends a GET request to /api/users
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: dvader",
        "name": "dvader",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: master",
        "name": "master",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [
          "admin"
        ],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: palpatine",
        "name": "palpatine",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: pamidala",
        "name": "pamidala",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve all users with only details for his organizations and technical memberships
    When borgana sends a GET request to /api/users?withTechnicalMembership=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "bail.organa@localhost.localdomain",
        "emails": [{
          "address": "bail.organa@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "technicalMembership": {
          "id": "@alphanumeric",
          "organizationId": "@idOf: Old Republic",
          "roles": [],
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601",
          "userId": "@idOf: c3po"
        },
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: dvader",
        "name": "dvader",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "dark.vader@localhost.localdomain",
        "emails": [{
          "address": "dark.vader@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: master",
        "name": "master",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [
          "admin"
        ],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: palpatine",
        "name": "palpatine",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "palpatine@localhost.localdomain",
        "emails": [{
          "address": "palpatine@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: pamidala",
        "name": "pamidala",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "padme.amidala@localhost.localdomain",
        "emails": [{
          "address": "padme.amidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: Only Probe Dock admins should be able to retrieve all users with only details for organizations and memberships
    When master sends a GET request to /api/users?withOrganizations=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "bail.organa@localhost.localdomain",
        "emails": [{
          "address": "bail.organa@localhost.localdomain",
          "active": false
        }],
         "organizations": [{
          "id": "@idOf: Old Republic",
          "name": "old-republic",
          "public": true,
          "displayName": "Old Republic",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }, {
          "id": "@idOf: Galactic Empire",
          "name": "galactic-empire",
          "public": true,
          "displayName": "Galactic Empire",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "organizations": [{
          "id": "@idOf: Old Republic",
          "name": "old-republic",
          "public": true,
          "displayName": "Old Republic",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: dvader",
        "name": "dvader",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "dark.vader@localhost.localdomain",
        "emails": [{
          "address": "dark.vader@localhost.localdomain",
          "active": false
        }],
        "organizations": [{
          "id": "@idOf: Galactic Empire",
          "name": "galactic-empire",
          "public": true,
          "displayName": "Galactic Empire",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "han.solo@localhost.localdomain",
        "emails": [{
          "address": "han.solo@localhost.localdomain",
          "active": false
        }],
        "organizations": [{
          "id": "@idOf: Rebel Alliance",
          "name": "rebel-alliance",
          "public": false,
          "displayName": "Rebel Alliance",
          "projectsCount": 0,
          "membershipsCount": 2,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "luke.skywalker@localhost.localdomain",
        "emails": [{
          "address": "luke.skywalker@localhost.localdomain",
          "active": false
        }],
        "organizations": [{
          "id": "@idOf: Rebel Alliance",
          "name": "rebel-alliance",
          "public": false,
          "displayName": "Rebel Alliance",
          "projectsCount": 0,
          "membershipsCount": 2,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: master",
        "name": "master",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "@email",
        "emails": [{
          "address": "@email",
          "active": false
        }],
        "organizations": [],
        "active": true,
        "roles": [
          "admin"
        ],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: palpatine",
        "name": "palpatine",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "palpatine@localhost.localdomain",
        "emails": [{
          "address": "palpatine@localhost.localdomain",
          "active": false
        }],
        "organizations": [{
          "id": "@idOf: Galactic Empire",
          "name": "galactic-empire",
          "public": true,
          "displayName": "Galactic Empire",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: pamidala",
        "name": "pamidala",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "padme.amidala@localhost.localdomain",
        "emails": [{
          "address": "padme.amidala@localhost.localdomain",
          "active": false
        }],
        "organizations": [{
          "id": "@idOf: Old Republic",
          "name": "old-republic",
          "public": true,
          "displayName": "Old Republic",
          "projectsCount": 0,
          "membershipsCount": 3,
          "createdAt": "@iso8601",
          "updatedAt": "@iso8601"
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve a user by e-mail
    When borgana sends a GET request to /api/users?email=luke.skywalker@localhost.localdomain
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to search a user by name
    When borgana sends a GET request to /api/users?search=hsolo
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to search a user by e-mail
    When borgana sends a GET request to /api/users?search=han
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve a user by name
    When borgana sends a GET request to /api/users?name=hsolo
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @regression
  Scenario: An organization member should be able to retrieve a user by name (in different case)
    When borgana sends a GET request to /api/users?name=hSoLo
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: hsolo",
        "name": "hsolo",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve inactive users
    When borgana sends a GET request to /api/users?active=false
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": false,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve the users in his organization
    When borgana sends a GET request to /api/users?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "bail.organa@localhost.localdomain",
        "emails": [{
          "address": "bail.organa@localhost.localdomain",
          "active": false
        }],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }, {
        "id": "@idOf: pamidala",
        "name": "pamidala",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "padme.amidala@localhost.localdomain",
        "emails": [{
          "address": "padme.amidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve technical users
    When borgana sends a GET request to /api/users?technical=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: c3po",
        "name": "c3po",
        "technical": true,
        "organizationId": "@idOf: Old Republic",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to retrieve users from another organization
    When borgana sends a GET request to /api/users?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
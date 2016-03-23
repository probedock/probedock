@api @users
Feature: Users

  Retrieving users with additional informations


  Background:
    Given user master who is a Probe Dock admin exists

    # Create private organization with 2 users
    And private organization Rebel Alliance exists
    And user hsolo with primary email hsolo@localhost.localdomain who is a member of Rebel Alliance exists
    And user lskywalker with primary email lskywalker@localhost.localdomain who is a member of Rebel Alliance exists

    # Create public organization with 2 users
    And public organization Old Republic exists
    And user borgana with primary email borgana@localhost.localdomain who is a member of Old Republic exists
    And user pamidala with primary email pamidala@localhost.localdomain who is a member of Old Republic exists
    And user c3po who is a technical user of Old Republic exists

    # Create public organization with 3 users
    And public organization Galactic Empire exists
    And user dvader with primary email dvader@localhost.localdomain who is a member of Galactic Empire exists
    And user palpatine with primary email palpatine@localhost.localdomain who is a member of Galactic Empire exists
    And user borgana is also a member of Galactic Empire



  Scenario: An organization member should be able to retrieve all users with only details for his organizations.
    When borgana sends a GET request to /api/users
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "borgana@localhost.localdomain",
        "emails": [{
          "address": "borgana@localhost.localdomain",
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
        "primaryEmail": "dvader@localhost.localdomain",
        "emails": [{
          "address": "dvader@localhost.localdomain",
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
        "active": true,
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
        "primaryEmail": "pamidala@localhost.localdomain",
        "emails": [{
          "address": "pamidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An anonymous user should be able to retrieve all users without details.
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
        "active": true,
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



  Scenario: An organization member should be able to retrieve all users with only details for his organizations and technical memberships.
    When borgana sends a GET request to /api/users?withTechnicalMembership=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "borgana@localhost.localdomain",
        "emails": [{
          "address": "borgana@localhost.localdomain",
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
        "primaryEmail": "dvader@localhost.localdomain",
        "emails": [{
          "address": "dvader@localhost.localdomain",
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
        "active": true,
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
        "primaryEmail": "pamidala@localhost.localdomain",
        "emails": [{
          "address": "pamidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: Only Probe Dock admins should be able to retrieve all users with only details for organizations where they are member and organization memberships.
    When master sends a GET request to /api/users?withOrganizations=true
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "borgana@localhost.localdomain",
        "emails": [{
          "address": "borgana@localhost.localdomain",
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
        "primaryEmail": "dvader@localhost.localdomain",
        "emails": [{
          "address": "dvader@localhost.localdomain",
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
        "primaryEmail": "hsolo@localhost.localdomain",
        "emails": [{
          "address": "hsolo@localhost.localdomain",
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
        "primaryEmail": "lskywalker@localhost.localdomain",
        "emails": [{
          "address": "lskywalker@localhost.localdomain",
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
        "primaryEmail": "pamidala@localhost.localdomain",
        "emails": [{
          "address": "pamidala@localhost.localdomain",
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



  Scenario: An organization member should be able to retrieve a user by its email.
    When borgana sends a GET request to /api/users?email=lskywalker@localhost.localdomain
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: lskywalker",
        "name": "lskywalker",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to retrieve a user by its user name.
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



  Scenario: An organization member should be able to retrieve users filtered by organization.
    When borgana sends a GET request to /api/users?organizationId={@idOf: Old Republic}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "id": "@idOf: borgana",
        "name": "borgana",
        "technical": false,
        "primaryEmailMd5": "@md5",
        "primaryEmail": "borgana@localhost.localdomain",
        "emails": [{
          "address": "borgana@localhost.localdomain",
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
        "primaryEmail": "pamidala@localhost.localdomain",
        "emails": [{
          "address": "pamidala@localhost.localdomain",
          "active": false
        } ],
        "active": true,
        "roles": [],
        "createdAt": "@iso8601"
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should not be able to retrieve users from another organization when filtered by organization.
    When borgana sends a GET request to /api/users?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
@api @user-registration
Feature: User registration

  People who want to test Probe Dock should be able to register a new user account.

  Since an organization is needed to create projects and publish test results, a new user
  should also be able to create their own organization when registering. The user will
  automatically be assigned as the administrator of the new organization.



  Scenario: A new user should be able to register and create an organization
    Given user registrations are enabled
    When nobody sends a POST request with the following JSON to /api/registrations:
      """
      {
        "user": {
          "name": "borgana",
          "primaryEmail": "bail.organa@galactic-republic.org"
        },
        "organization": {
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "public": false
        }
      }
      """
    Then the response code should be 201
    And the response body should be the following JSON:
      """
      {
        "id": "@alphanumeric",
        "user": {
          "id": "@alphanumeric",
          "name": "borgana",
          "active": false,
          "technical": false,
          "roles": [],
          "primaryEmailMd5": "0f4524deed700a48dfd39cd46eee8d8f",
          "createdAt": "@iso8601"
        },
        "organization": {
          "id": "@alphanumeric",
          "name": "rebel-alliance",
          "public": false
        },
        "completed": false,
        "expiresAt": "@iso8601",
        "createdAt": "@iso8601"
      }
      """
    And the following changes should have occurred: +1 user, +1 email, +1 organization, +1 membership, +1 user registration, +1 mailer job
    And the following user registration should be in the database:
      """
      userId: "@json(/user/id)"
      organizationId: "@json(/organization/id)"
      completed: false
      """
    And the following user should be in the database:
      """
      id: "@json(/user/id)"
      name: "borgana"
      active: false
      primaryEmail: "bail.organa@galactic-republic.org"
      createdAt: "@json(/user/createdAt)"
      """
    And the following organization should be in the database:
      """
      id: "@json(/organization/id)"
      name: "rebel-alliance"
      displayName: "Rebel Alliance"
      public: false
      active: false
      membershipsCount: 1
      """
    And the following membership should be in the database:
      """
      userId: "@json(/user/id)"
      organizationId: "@json(/organization/id)"
      organizationEmail: "bail.organa@galactic-republic.org"
      roles: [admin]
      """
    And a registration e-mail for the last created registration should be queued for sending



  Scenario: A new user should not be able to register if user registrations are disabled
    Given user registrations are disabled
    When nobody sends a POST request with the following JSON to /api/registrations:
      """
      {
        "user": {
          "name": "borgana",
          "primaryEmail": "bail.organa@galactic-republic.org"
        },
        "organization": {
          "name": "rebel-alliance",
          "displayName": "Rebel Alliance",
          "public": false
        }
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @validation
  Scenario: A new user should not be able to register with the same name as an existing user or create an organization with the same name as an existing organization
    Given organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    And user registrations are enabled
    When nobody sends a POST request with the following JSON to /api/registrations:
      """
      {
        "user": {
          "name": "palpatine",
          "primaryEmail": "supreme-chancelor@galactic-republic.org"
        },
        "organization": {
          "name": "galactic-republic",
          "displayName": "Galactic Republic",
          "public": true
        }
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | path               | message                                  |
      | /user/name         | User name has already been taken         |
      | /organization/name | Organization name has already been taken |
    And nothing should have been added or deleted



  @otp
  Scenario: A new user should be able to retrieve the registration he created with the OTP he received in the registration e-mail
    Given user borgana registered with e-mail bail.organa@galactic-republic.org and created private organization Rebel Alliance
    When nobody sends a GET request to /api/registrations?otp={@registrationOtpOf: borgana}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@alphanumeric",
          "user": {
            "id": "@idOf: borgana",
            "name": "borgana",
            "active": false,
            "technical": false,
            "roles": [],
            "primaryEmailMd5": "0f4524deed700a48dfd39cd46eee8d8f",
            "createdAt": "@iso8601"
          },
          "organization": {
            "id": "@idOf: Rebel Alliance",
            "name": "rebel-alliance",
            "public": false
          },
          "completed": false,
          "expiresAt": "@iso8601",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to retrieve a user registration
    Given user borgana registered with e-mail bail.organa@galactic-republic.org and created private organization Rebel Alliance
    When nobody sends a GET request to /api/registrations
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  Scenario: A new user should be able to set his password and activate his account with the OTP he received in the registration e-mail
    Given user borgana registered with e-mail bail.organa@galactic-republic.org and created private organization Rebel Alliance
    When nobody sends a PATCH request with the following JSON to /api/users/{@idOf: borgana}?registrationOtp={@registrationOtpOf: borgana}:
      """
      {
        "active": true,
        "password": "sekr3t",
        "passwordConfirmation": "sekr3t"
      }
      """
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      {
        "id": "@idOf: borgana",
        "name": "borgana",
        "active": true,
        "technical": false,
        "roles": [],
        "primaryEmailMd5": "0f4524deed700a48dfd39cd46eee8d8f",
        "createdAt": "@iso8601"
      }
      """
    And nothing should have been added or deleted
    And the following user registration should be in the database:
      """
      userId: "@idOf: borgana"
      organizationId: "@idOf: Rebel Alliance"
      completed: true
      """
    And the following user should be in the database:
      """
      id: "@idOf: borgana"
      name: "borgana"
      active: true
      primaryEmail: "bail.organa@galactic-republic.org"
      createdAt: "@json(/createdAt)"
      """
    And the following organization should be in the database:
      """
      id: "@idOf: Rebel Alliance"
      name: "rebel-alliance"
      displayName: "Rebel Alliance"
      public: false
      active: true
      membershipsCount: 1
      """
    And the following membership should be in the database:
      """
      userId: "@idOf: borgana"
      organizationId: "@idOf: Rebel Alliance"
      organizationEmail: "bail.organa@galactic-republic.org"
      roles: [admin]
      """



  @authorization
  Scenario: A new user should not be able to rename his account when activating it
    Given user borgana registered with e-mail bail.organa@galactic-republic.org and created private organization Rebel Alliance
    When nobody sends a PATCH request with the following JSON to /api/users/{@idOf: borgana}?registrationOtp={@registrationOtpOf: borgana}:
      """
      {
        "name": "mmothma",
        "active": true,
        "password": "sekr3t",
        "passwordConfirmation": "sekr3t"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted
    And the following user registration should be in the database:
      """
      userId: "@idOf: borgana"
      organizationId: "@idOf: Rebel Alliance"
      completed: false
      """
    And the following user should be in the database:
      """
      id: "@idOf: borgana"
      name: "borgana"
      active: false
      primaryEmail: "bail.organa@galactic-republic.org"
      createdAt: "@iso8601"
      """
    And the following organization should be in the database:
      """
      id: "@idOf: Rebel Alliance"
      name: "rebel-alliance"
      displayName: "Rebel Alliance"
      public: false
      active: false
      membershipsCount: 1
      """



  @search
  Scenario: An anonymous user should be able to check if a username is already taken
    Given user borgana exists with e-mail bail.organa@galactic-republic.org
    When nobody sends a GET request to /api/users?name=borgana
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: borgana",
          "name": "borgana",
          "active": true,
          "technical": false,
          "roles": [],
          "primaryEmailMd5": "0f4524deed700a48dfd39cd46eee8d8f",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An anonymous user should be able to check if a username is free
    Given user palpatine exists with e-mail supreme-chancellor@galactic-republic.org
    When nobody sends a GET request to /api/users?name=borgana
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      []
      """
    And nothing should have been added or deleted



  @search
  Scenario: An anonymous user should be able to check if an e-mail is already taken
    Given user borgana exists with e-mail bail.organa@galactic-republic.org
    When nobody sends a GET request to /api/users?email=bail.organa@galactic-republic.org
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [
        {
          "id": "@idOf: borgana",
          "name": "borgana",
          "active": true,
          "technical": false,
          "roles": [],
          "primaryEmailMd5": "0f4524deed700a48dfd39cd46eee8d8f",
          "createdAt": "@iso8601"
        }
      ]
      """
    And nothing should have been added or deleted



  @search
  Scenario: An anonymous user should be able to check if an e-mail is free
    Given user palpatine exists with e-mail supreme-chancellor@galactic-republic.org
    When nobody sends a GET request to /api/users?email=bail.organa@galactic-republic.org
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      []
      """
    And nothing should have been added or deleted

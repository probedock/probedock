@technical-users
Feature: Technical users

  When publishing test results to Probe Dock from a continuous integration pipeline,
  organization members want to avoid using their personal credentials to authenticate
  to Probe Dock. A "technical" user is needed, which is not a human user but is
  authorized to publish test results.

  A technical user:
  - cannot log in
  - does not have an e-mail address
  - belongs to one and only one organization
  - can be created and managed by the organization admin



  Scenario: An organization admin should be able to create a technical user.
    Given organization Initech exists
    And user blumbergh who is an admin of Initech exists
    When blumbergh sends a POST request with the following JSON to /api/users:
      """
      {
        "name": "milton",
        "technical": true,
        "organizationId": "@idOf: Initech"
      }
      """
    Then the response code should be 201
    And the response body should be the following JSON:
      """
      {
        "id": "@alphanumeric",
        "name": "milton",
        "active": true,
        "technical": true,
        "roles": [],
        "organizationId": "@idOf: Initech",
        "createdAt": "@iso8601"
      }
      """
    And the changes to the number of records in the database should be as follows: +1 user, +1 membership
    And there should be a user in the database corresponding to the response body



  @authorization
  Scenario: An organization member should not be able to create a technical user.
    Given organization Initech exists
    And user pgibbons who is a member of Initech exists
    When pgibbons sends a POST request with the following JSON to /api/users:
      """
      {
        "name": "milton",
        "technical": true,
        "organizationId": "@idOf: Initech"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database



  @validation
  Scenario: An organization admin should not be able to create a technical user with a password.
    Given organization Initech exists
    And user blumbergh who is an admin of Initech exists
    When blumbergh sends a POST request with the following JSON to /api/users:
      """
      {
        "name": "milton",
        "technical": true,
        "organizationId": "@idOf: Initech",
        "password": "foo"
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | path      | message                |
      | /password | Password must be blank |
    And there should be no changes to the number of records in the database



  @authentication
  Scenario: A technical user should not be able to log in.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    When milton authenticates by sending a POST request to /api/authentication with Basic password foo
    Then the response should be HTTP 401 with the following errors:
      | message                             |
      | Technical users cannot authenticate |
    And there should be no changes to the number of records in the database



  @validation
  Scenario: An administrator should not be able to invite a technical user to another organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And organization Chotchkies exists
    And user god who is an administrator exists
    When god sends a POST request with the following JSON to /api/memberships:
      """
      {
        "organizationId": "@idOf: Chotchkies",
        "userId": "@idOf: milton"
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | path    | message                                                   |
      | /userId | User must not be a technical user of another organization |
    And there should be no changes to the number of records in the database



  Scenario: An organization admin should be able to update a technical user of the organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And user blumbergh who is an admin of Initech exists
    When blumbergh sends a PATCH request with the following JSON to /api/users/{@idOf: milton}:
      """
      {
        "name": "basement",
        "active": false
      }
      """
    Then the response body should be the following JSON:
      """
      {
        "id": "@idOf: milton",
        "name": "basement",
        "active": false,
        "technical": true,
        "roles": [],
        "organizationId": "@idOf: Initech",
        "createdAt": "@iso8601"
      }
      """
    And there should be no changes to the number of records in the database
    And there should be a user in the database corresponding to the response body



  @authorization
  Scenario: An organization member should not be able to update a technical user of the organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And user pgibbons who is a member of Initech exists
    When pgibbons sends a PATCH request with the following JSON to /api/users/{@idOf: milton}:
      """
      {
        "name": "basement",
        "active": false
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database



  @authorization
  Scenario: An organization admin should not be able to update a technical user of another organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And organization Chotchkies exists
    And user stan who is an admin of Chotchkies exists
    When stan sends a PATCH request with the following JSON to /api/users/{@idOf: milton}:
      """
      {
        "name": "basement",
        "active": false
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database



  @authentication
  Scenario: An organization admin should be able to create an authentication token for a technical user of the organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And user blumbergh who is an admin of Initech exists
    When blumbergh sends a POST request with the following JSON to /api/tokens:
      """
      {
        "userId": "@idOf: milton"
      }
      """
    Then the response code should be 201
    And the response body should be the following JSON:
      """
      {
        "userId": "@idOf: milton",
        "token": "@string"
      }
      """
    And there should be no changes to the number of records in the database



  @authorization
  Scenario: An organization member should not be able to create an authentication token for a technical user of the organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And user pgibbons who is a member of Initech exists
    When pgibbons sends a POST request with the following JSON to /api/tokens:
      """
      {
        "userId": "@idOf: milton"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database



  @authorization
  Scenario: An organization member should not be able to create an authentication token for a technical user of another organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And organization Chotchkies exists
    And user joanna who is a member of Chotchkies exists
    When joanna sends a POST request with the following JSON to /api/tokens:
      """
      {
        "userId": "@idOf: milton"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database



  @authorization
  Scenario: An organization admin should not be able to create an authentication token for a technical user of another organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And organization Chotchkies exists
    And user stan who is an admin of Chotchkies exists
    When stan sends a POST request with the following JSON to /api/tokens:
      """
      {
        "userId": "@idOf: milton"
      }
      """
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And there should be no changes to the number of records in the database

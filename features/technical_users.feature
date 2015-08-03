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
    And user blumbergh who is an admin for Initech exists
    When blumbergh POSTs JSON to /api/users with:
      | property       | value          |
      | name           | milton         |
      | technical      | true           |
      | organizationId | @idOf: Initech |
    Then the response code should be 201
    And the response body should include in addition to the request body:
      | property  | value         |
      | id        | @alphanumeric |
      | active    | true          |
      | roles     | []            |
      | createdAt | @iso8601      |
    And the changes to the number of records in the database should be as follows: +1 user, +1 membership
    And there should be a user in the database corresponding to the response body

  Scenario: A technical user should not be able to log in.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    When milton authenticates by POSTing to /api/authentication with Basic password foo
    Then the response should be HTTP 401 with the following errors:
      | message                             |
      | Technical users cannot authenticate |
    And there should be no changes to the number of records in the database

  Scenario: An administrator should not be able to invite a technical user to another organization.
    Given organization Initech exists
    And user milton who is a technical user for Initech exists
    And organization Chotchkies exists
    And user god who is an administrator exists
    When god POSTs JSON to /api/memberships with:
      | property       | value            |
      | organizationId | idOf: Chotchkies |
      | userId         | idOf: milton     |
    Then the response should be HTTP 422 with the following errors:
      | path    | message                                                   |
      | /userId | User must not be a technical user of another organization |
    And there should be no changes to the number of records in the database

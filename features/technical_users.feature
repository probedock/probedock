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

  @wip
  Scenario: An organization admin should be able to create a technical user
    Given organization Initech exists
    And user blumbergh who is an admin for Initech exists
    When blumbergh POSTs JSON to /api/users with:
      | property       | value         |
      | name           | milton        |
      | technical      | true          |
      | organizationId | idOf: Initech |
    Then the response code should be 201
    And the response body should include in addition to the request body:
      | property  | value         |
      | id        | @alphanumeric |
      | active    | true          |
      | roles     | []            |
      | createdAt | @iso8601      |

@user-registration
Feature: User registration

  People who want to test Probe Dock should be able to register a new user account.

  Since an organization is needed to create projects and publish test results, a new user
  should also be able to create their own organization when registering. The user will
  automatically be assigned as the administrator of the new organization.



  Scenario: A new user should be able to register and create an organization.
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

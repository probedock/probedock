@api @metrics
Feature: Reports by day metrics

  Users should be able to retrieve the number of reports by day of an organization.
  The users can filter the by project and/or by user.
  Finally, the users can retrieve between 1 and 120 days of data.

  The following result is provided:
  - runsCount for each day
  - date for each day


  Background:
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And user lskywalker who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And test result report report 1 was generated 2 days ago for organization Rebel Alliance
    And test payload payload 1 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 1
    And test payload payload 2 sent by hsolo for version 1.0.0 of project X-Wing was used to generate report report 1
    And test result report report 2 was generated 2 days ago for organization Rebel Alliance
    And test payload payload 3 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 2
    And test result report report 3 was generated 1 days ago for organization Rebel Alliance
    And test payload payload 4 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 3
    And test result report report 4 was generated 1 days ago for organization Rebel Alliance
    And test payload payload 5 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 4
    And test result report report 5 was generated 1 days ago for organization Rebel Alliance
    And test payload payload 6 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 5
    And test result report report 6 was generated 1 days ago for organization Rebel Alliance
    And test payload payload 7 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 6
    And test result report report 7 was generated for organization Rebel Alliance
    And test payload payload 8 sent by lskywalker for version 1.0.0 of project X-Wing was used to generate report report 7
    And project Y-Wing exists within organization Rebel Alliance
    And test result report report 8 was generated 1 day ago for organization Rebel Alliance
    And test payload payload 9 sent by hsolo for version 1.0.0 of project Y-Wing was used to generate report report 8
    And test payload payload 10 sent by lskywalker for version 1.0.0 of project Y-Wing was used to generate report report 8
    And test result report report 9 was generated for organization Rebel Alliance
    And test payload payload 11 sent by hsolo for version 1.0.0 of project Y-Wing was used to generate report report 9
    And assuming 3 days is set to retrieve the reports by day



  Scenario: An organization member should be able to get the organization's reports by day metrics
    When hsolo sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "date": "@date(2 days ago)",
        "runsCount": 2
      }, {
        "date": "@date(1 day ago)",
        "runsCount": 5
      }, {
        "date": "@date(today)",
        "runsCount": 2
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the organization's reports by day metrics filtered by project
    When hsolo sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "date": "@date(2 days ago)",
        "runsCount": 2
      }, {
        "date": "@date(1 day ago)",
        "runsCount": 4
      }, {
        "date": "@date(today)",
        "runsCount": 1
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the organization's reports by day metrics filtered by user
    When hsolo sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&userIds[]={@idOf: hsolo}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "date": "@date(2 days ago)",
        "runsCount": 1
      }, {
        "date": "@date(1 day ago)",
        "runsCount": 1
      }, {
        "date": "@date(today)",
        "runsCount": 1
      }]
      """
    And nothing should have been added or deleted



  Scenario: An organization member should be able to get the organization's reports by day metrics filtered by project and user
    When hsolo sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}&userIds[]={@idOf: hsolo}
    Then the response code should be 200
    And the response body should be the following JSON:
      """
      [{
        "date": "@date(2 days ago)",
        "runsCount": 1
      }, {
        "date": "@date(1 day ago)",
        "runsCount": 0
      }, {
        "date": "@date(today)",
        "runsCount": 0
      }]
      """
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the reports from another organization
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the reports from another organization filtered by projects
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the reports from another organization filtered by users
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&userIds[]={@idOf: lskywalker}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An organization member should not be able to get the reports from another organization filtered by projects and users
    Given private organization Galactic Republic exists
    And user palpatine who is an admin of Galactic Republic exists
    When palpatine sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}&userIds[]={@idOf: lskywalker}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the reports from private organization
    When nobody sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the reports from private organization filtered by projects
    When nobody sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the reports from private organization filtered by users
    When nobody sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&userIds[]={@idOf: lskywalker}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted



  @authorization
  Scenario: An anonymous user should not be able to get the reports from private organization filtered by projects and users
    When nobody sends a GET request to /api/metrics/reportsByDay?organizationId={@idOf: Rebel Alliance}&projectIds[]={@idOf: X-Wing}&userIds[]={@idOf: lskywalker}
    Then the response should be HTTP 403 with the following errors:
      | message                                        |
      | You are not authorized to perform this action. |
    And nothing should have been added or deleted

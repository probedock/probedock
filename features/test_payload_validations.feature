@api @validation
Feature: Test payload validations

  Probe Dock should accept valid JSON test reports for processing,
  but should refuse invalid reports and return appropriate error messages.



  Scenario: A valid JSON payload should be accepted
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "0.4.6",
        "duration": 1529,
        "results": [
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit proin",
            "p": true,
            "d": 2058,
            "c": "RSpec",
            "g": [ "crud", "unit", "performance" ],
            "t": [ "JIRA-857" ],
            "a": {
              "lorem.ipsum.dolor": "lorem ipsum dolor sit"
            }
          },
          {
            "n": "Lorem ipsum",
            "p": true,
            "d": 1664,
            "t": [ "JIRA-691" ]
          },
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit",
            "p": true,
            "d": 876,
            "c": "SoapUI",
            "g": [],
            "t": [ "JIRA-485", "JIRA-573" ],
            "a": {
              "lorem.ipsum.dolor": "lorem"
            }
          }
        ],
        "reports": [
          {
            "uid": "32d4d802-c436-11e5-9912-ba0be0483c18"
          }
        ]
      }
      """
    Then the response should be HTTP 202 with the following JSON:
      """
      {
        "receivedAt": "@iso8601",
        "payloads": [
          {
            "id": "@uuid",
            "projectId": "@idOf: X-Wing",
            "projectVersion": "0.4.6",
            "duration": 1529,
            "runnerId": "@idOf: hsolo",
            "endedAt": "@iso8601",
            "bytes": "@integer"
          }
        ]
      }
      """
    And the following changes should have occurred: +1 test payload, +1 process next test payload job



  Scenario: A valid JSON payload should be accepted with Probe Dock's custom content type
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following application/vnd.probedock.payload.v1+json data to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "0.4.6",
        "duration": 1529,
        "results": [
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit proin",
            "p": true,
            "d": 2058,
            "c": "RSpec",
            "g": [ "crud", "unit", "performance" ],
            "t": [ "JIRA-857" ],
            "a": {
              "lorem.ipsum.dolor": "lorem ipsum dolor sit"
            }
          }
        ],
        "reports": [
          {
            "uid": "32d4d802-c436-11e5-9912-ba0be0483c18"
          }
        ]
      }
      """
    Then the response should be HTTP 202 with the following JSON:
      """
      {
        "receivedAt": "@iso8601",
        "payloads": [
          {
            "id": "@uuid",
            "projectId": "@idOf: X-Wing",
            "projectVersion": "0.4.6",
            "duration": 1529,
            "runnerId": "@idOf: hsolo",
            "endedAt": "@iso8601",
            "bytes": "@integer"
          }
        ]
      }
      """
    And the following changes should have occurred: +1 test payload, +1 process next test payload job



  Scenario: A valid JSON payload should be accepted with Probe Dock's custom content type with the old naming convention
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following application/vnd.probe-dock.payload.v1+json data to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "0.4.6",
        "duration": 1529,
        "results": [
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit proin",
            "p": true,
            "d": 2058,
            "c": "RSpec",
            "g": [ "crud", "unit", "performance" ],
            "t": [ "JIRA-857" ],
            "a": {
              "lorem.ipsum.dolor": "lorem ipsum dolor sit"
            }
          }
        ],
        "reports": [
          {
            "uid": "32d4d802-c436-11e5-9912-ba0be0483c18"
          }
        ]
      }
      """
    Then the response should be HTTP 202 with the following JSON:
      """
      {
        "receivedAt": "@iso8601",
        "payloads": [
          {
            "id": "@uuid",
            "projectId": "@idOf: X-Wing",
            "projectVersion": "0.4.6",
            "duration": 1529,
            "runnerId": "@idOf: hsolo",
            "endedAt": "@iso8601",
            "bytes": "@integer"
          }
        ]
      }
      """
    And the following changes should have occurred: +1 test payload, +1 process next test payload job



  Scenario: A payload of the wrong content type should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following text/plain data to /api/publish:
      """
      Foo
      """
    Then the response should be HTTP 415 with the following errors:
      | message                                                                             |
      | The content type of the test payload should be application/json or application/xml. |
    And nothing should have been added or deleted



  Scenario: A payload sent as a multipart/form-data parameter with the wrong content type should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a multipart/form-data POST request with the following text/plain data as the payload parameter to /api/publish:
      """
      Foo
      """
    Then the response should be HTTP 415 with the following errors:
      | message                                                                             |
      | The content type of the test payload should be application/json or application/xml. |
    And nothing should have been added or deleted



  Scenario: A payload sent as the wrong multipart/form-data parameter should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a multipart/form-data POST request with the following JSON data as the file parameter to /api/publish:
      """
      {
        "foo": "bar"
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | reason  | locationType      | location | message                 |
      | missing | multipartFormData | payload  | This value is required. |
    And nothing should have been added or deleted



  Scenario: An empty JSON payload should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {}
      """
    Then the response should be HTTP 422 with the following errors:
      | reason  | locationType | location   | message                 |
      | missing | json         | /projectId | This value is required. |
      | missing | json         | /version   | This value is required. |
      | missing | json         | /duration  | This value is required. |
      | missing | json         | /results   | This value is required. |
    And nothing should have been added or deleted



  Scenario: A JSON payload with no test results should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "0.4.6",
        "duration": 1529,
        "results": []
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | reason | locationType | location | message                     |
      | empty  | json         | /results | This value cannot be empty. |
    And nothing should have been added or deleted



  Scenario: A JSON payload with values of the wrong type should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {
        "projectId": 123,
        "version": [ "1.2.3" ],
        "duration": 2.4,
        "endedAt": false,
        "results": [
          true,
          {
            "k": { "foo": "bar" },
            "n": 123,
            "p": [ true ],
            "v": "active",
            "d": "asd",
            "m": false,
            "c": 234,
            "g": { "foo": "bar" },
            "t": false,
            "a": [ "foo", "bar" ]
          }
        ],
        "reports": {
          "uid": "foo"
        }
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | reason       | locationType | location     | message                          |
      | wrongType    | json         | /projectId   | This value is of the wrong type. |
      | wrongType    | json         | /version     | This value is of the wrong type. |
      | notAnInteger | json         | /duration    | This value is not an integer.    |
      | wrongType    | json         | /endedAt     | This value is of the wrong type. |
      | wrongType    | json         | /results/0   | This value is of the wrong type. |
      | missing      | json         | /results/0/n | This value is required.          |
      | missing      | json         | /results/0/d | This value is required.          |
      | wrongType    | json         | /results/1/k | This value is of the wrong type. |
      | wrongType    | json         | /results/1/n | This value is of the wrong type. |
      | wrongType    | json         | /results/1/p | This value is of the wrong type. |
      | wrongType    | json         | /results/1/v | This value is of the wrong type. |
      | wrongType    | json         | /results/1/d | This value is of the wrong type. |
      | wrongType    | json         | /results/1/m | This value is of the wrong type. |
      | wrongType    | json         | /results/1/c | This value is of the wrong type. |
      | wrongType    | json         | /results/1/g | This value is of the wrong type. |
      | wrongType    | json         | /results/1/t | This value is of the wrong type. |
      | wrongType    | json         | /results/1/a | This value is of the wrong type. |
      | wrongType    | json         | /reports     | This value is of the wrong type. |
    And nothing should have been added or deleted



  Scenario: A JSON payload with spaces in tag should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "0.4.6",
        "duration": 1529,
        "results": [
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit proin",
            "p": true,
            "d": 2058,
            "c": "RSpec",
            "g": [ "tag with spaces" ],
            "t": [ "JIRA-857" ],
            "a": {
              "lorem.ipsum.dolor": "lorem ipsum dolor sit"
            }
          }
        ],
        "reports": [
          {
            "uid": "32d4d802-c436-11e5-9912-ba0be0483c18"
          }
        ]
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | reason        | locationType | location       | message                            |
      | invalidFormat | json         | /results/0/g/0 | This value is of the wrong format. |
    And nothing should have been added or deleted



  Scenario: A JSON payload with values that are out of bounds should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    And hsolo sends a POST request with the following JSON to /api/publish:
      """
      {
        "projectId": "@idOf: X-Wing",
        "version": "1.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6.2.3.4.5.6",
        "duration": -23,
        "results": [
          {
            "n": "Lorem ipsum",
            "p": true,
            "d": 1664,
            "t": [ "JIRA-691" ]
          },
          {
            "n": "Lorem ipsum dolor sit amet consectetuer adipiscing elit proin ipsum dolor sit amet consectetuer adipiscing elit proin ipsum dolor sit amet consectetuer adipiscing elit proin ipsum dolor sit amet consectetuer adipiscing elit proin ipsum dolor sit amet consectetuer adipiscing elit proin",
            "d": -2,
            "c": "123456789012345678901234567890123456789012345678901",
            "g": [ "crud", "unit", "12345678901234567890123456789012345678901234567890123" ],
            "t": [ "JIRA-857" ],
            "a": {
              "lorem.ipsum.dolor": "lorem ipsum dolor sit"
            }
          }
        ],
        "reports": [
          {
            "uid": "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012"
          }
        ]
      }
      """
    Then the response should be HTTP 422 with the following errors:
      | reason                  | locationType | location       | message                                                                     |
      | tooLong                 | json         | /version       | This value is too long (the maximum is 100 while the actual length is 101). |
      | notGreaterThanOrEqualTo | json         | /duration      | This value is too small.                                                    |
      | tooLong                 | json         | /results/1/n   | This value is too long (the maximum is 255 while the actual length is 285). |
      | notGreaterThanOrEqualTo | json         | /results/1/d   | This value is too small.                                                    |
      | tooLong                 | json         | /results/1/c   | This value is too long (the maximum is 50 while the actual length is 51).   |
      | tooLong                 | json         | /results/1/g/2 | This value is too long (the maximum is 50 while the actual length is 53).   |
      | tooLong                 | json         | /reports/0/uid | This value is too long (the maximum is 100 while the actual length is 102). |
    And nothing should have been added or deleted

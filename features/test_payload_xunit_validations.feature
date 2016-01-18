@api @validation
Feature: xUnit test payload validations

  Probe Dock should accept valid XML xUnit test reports for processing,
  but should refuse invalid reports and return appropriate error messages.



  Scenario: A valid xUnit payload should be accepted
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite name="rspec" tests="3" failures="1" errors="0" time="0.235481" timestamp="2016-01-15T15:22:41+01:00">
        <properties />
        <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.031456" />
        <testcase classname="spec.models.a_spec" name="It might work" file="./spec/models/a_spec.rb">
          <skipped />
        </testcase>
        <testcase classname="spec.models.b_spec" name="It could work" file="./spec/models/b_spec.rb" time="0.050373">
          <failure message="bug" type="StandardError">
            <![CDATA[stack
            trace]]>
          </failure>
        </testcase>
      </testsuite>
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
            "duration": 235,
            "runnerId": "@idOf: hsolo",
            "endedAt": "@iso8601",
            "bytes": "@integer"
          }
        ]
      }
      """
    And the following changes should have occurred: +1 test payload, +1 process next test payload job



  Scenario: An xUnit payload with no "time" attribute in the <testsuite> tag should be accepted if the Probe-Dock-Duration header is sent
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And the Probe-Dock-Duration header is set to 5106
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <testsuite name="rspec" tests="1" failures="0" errors="0" timestamp="2016-01-15T15:22:41+01:00">
        <properties />
        <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.031456" />
      </testsuite>
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
            "duration": 5106,
            "runnerId": "@idOf: hsolo",
            "endedAt": "@iso8601",
            "bytes": "@integer"
          }
        ]
      }
      """
    And the following changes should have occurred: +1 test payload, +1 process next test payload job



  Scenario: An xUnit payload with no <testsuite> tag should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <fubar />
      """
    Then the response should be HTTP 422 with the following errors:
      | reason  | locationType | location   | message                 |
      | missing | xpath        | /testsuite | This value is required. |
    And nothing should have been added or deleted



  Scenario: An xUnit payload with no <testcase> tags should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <testsuite name="rspec" tests="3" failures="1" errors="0" time="0.235481" timestamp="2016-01-15T15:22:41+01:00">
        <properties />
      </testsuite>
      """
    Then the response should be HTTP 422 with the following errors:
      | reason | locationType | location            | message                     |
      | empty  | xpath        | /testsuite/testcase | This value cannot be empty. |
    And nothing should have been added or deleted



  Scenario: An xUnit payload with various missing values should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <testsuite>
        <properties />
        <testcase time="0.24" />
        <testcase name="foo" />
        <testcase name="bar" time="" />
        <testcase name="" time="12.40129" />
      </testsuite>
      """
    Then the response should be HTTP 422 with the following errors:
      | reason  | locationType | location                     | message                     |
      | missing | xpath        | /testsuite/@time             | This value is required.     |
      | missing | xpath        | /testsuite/testcase[1]/@name | This value is required.     |
      | missing | xpath        | /testsuite/testcase[2]/@time | This value is required.     |
      | empty   | xpath        | /testsuite/testcase[3]/@time | This value cannot be empty. |
      | empty   | xpath        | /testsuite/testcase[4]/@name | This value cannot be empty. |
    And nothing should have been added or deleted



  Scenario: An xUnit payload with invalid time attributes should be refused
    Given private organization Rebel Alliance exists
    And user hsolo who is a member of Rebel Alliance exists
    And project X-Wing exists within organization Rebel Alliance
    When the Probe-Dock-Project-Id header is set to {@idOf: X-Wing}
    And the Probe-Dock-Project-Version header is set to 0.4.6
    And hsolo sends a POST request with the following XML to /api/publish:
      """
      <testsuite time="">
        <properties />
        <testcase name="foo" time="0.24" />
        <testcase name="bar" time="asd" />
        <testcase name="baz" time="-2" />
      </testsuite>
      """
    Then the response should be HTTP 422 with the following errors:
      | reason                  | locationType | location                     | message                     |
      | empty                   | xpath        | /testsuite/@time             | This value cannot be empty. |
      | notNumeric              | xpath        | /testsuite/testcase[2]/@time | This value is not a number. |
      | notGreaterThanOrEqualTo | xpath        | /testsuite/testcase[3]/@time | This value is too small.    |
    And nothing should have been added or deleted

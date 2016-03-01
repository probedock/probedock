# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

RSpec.describe 'xUnit payload processing', probedock: { tags: %w(xunit) } do
  include PayloadProcessingSpecHelper

  let(:organization){ create :organization }
  let!(:projects){ Array.new(2){ create :project, organization: organization } }
  let!(:user){ create :org_member, organization: organization }

  it "should process an xUnit payload", probedock: { key: '5vvk' } do

    # prepare payload
    raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="3" failures="1" errors="0" time="5.207134" timestamp="2016-01-14T14:08:09+01:00">
  <properties />
  <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
  <testcase classname="spec.models.b_spec" name="It might work" file="./spec/models/b_spec.rb" time="0.050373">
    <failure message="something unexpected occurred" type="StandardError">
      <![CDATA[stack
trace]]>
    </failure>
  </testcase>
  <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
    <skipped/>
  </testcase>
</testsuite>
    EOS

    version = '1.2.3'
    payload_headers = generate_xml_payload_headers projects[0], version: version

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload, user: user, content_type: 'application/xml', headers: payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 5207, bytes: raw_payload.bytesize, endedAt: '2016-01-14T13:08:09.000Z'
    end

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3

    # check payload & report
    payload = check_payload @response_body, rawContents: raw_payload,
                            testsCount: 3, newTestsCount: 3,
                            resultsCount: 3, passedResultsCount: 2, inactiveResultsCount: 1, inactivePassedResultsCount: 1

    check_report payload, organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: version, projectId: projects[0].api_id

    # check the 3 new tests
    tests = check_tests projects[0], user, payload do
      check_test name: 'It should work'
      check_test name: 'It might work'
      check_test name: 'It could work'
    end

    # check the 3 results
    raw_results = [
      { n: 'It should work', d: 3 },
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, v: false }
    ]

    results = check_results raw_results, payload do
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[2], newTest: true
    end

    # check the descriptions of the 3 tests for the project version
    check_descriptions payload, tests do
      check_description results[0], resultsCount: 1
      check_description results[1], resultsCount: 1, passing: false
      check_description results[2], resultsCount: 1, active: false
    end
  end

  it "should process an xUnit payload with the Probe-Dock-Category header set", probedock: { key: 'klc3' } do

    # prepare payload
    raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="3" failures="1" errors="0" time="5.207134" timestamp="2016-01-14T14:08:09+01:00">
  <properties />
  <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
  <testcase classname="spec.models.b_spec" name="It might work" file="./spec/models/b_spec.rb" time="0.050373">
    <failure message="something unexpected occurred" type="StandardError">
      <![CDATA[stack
trace]]>
    </failure>
  </testcase>
  <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
    <skipped/>
  </testcase>
</testsuite>
    EOS

    version = '1.2.3'
    payload_headers = generate_xml_payload_headers projects[0], version: version, category: 'RSpec'

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload, user: user, content_type: 'application/xml', headers: payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 5207, bytes: raw_payload.bytesize, endedAt: '2016-01-14T13:08:09.000Z'
    end

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3, categories: 1

    # check payload & report
    payload = check_payload @response_body, rawContents: raw_payload,
                            testsCount: 3, newTestsCount: 3,
                            resultsCount: 3, passedResultsCount: 2, inactiveResultsCount: 1, inactivePassedResultsCount: 1,
                            categories: [ 'RSpec' ]

    check_report payload, organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: version, projectId: projects[0].api_id

    # check the 3 new tests
    tests = check_tests projects[0], user, payload do
      check_test name: 'It should work'
      check_test name: 'It might work'
      check_test name: 'It could work'
    end

    # check the 3 results
    raw_results = [
      { n: 'It should work', d: 3 },
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, v: false }
    ]

    results = check_results raw_results, payload do
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[2], newTest: true
    end

    # check the descriptions of the 3 tests for the project version
    check_descriptions payload, tests do
      check_description results[0], resultsCount: 1, category: 'RSpec'
      check_description results[1], resultsCount: 1, passing: false, category: 'RSpec'
      check_description results[2], resultsCount: 1, active: false, category: 'RSpec'
    end
  end

  it "should process an xUnit payload with multiple test suites", probedock: { key: '685u' } do

    # prepare payload
    raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="rspec" tests="2" failures="1" errors="0" time="3.207134" timestamp="2016-01-14T14:08:09+01:00">
    <properties />
    <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
    <testcase classname="spec.models.b_spec" name="It might work" file="./spec/models/b_spec.rb" time="0.050373">
      <failure message="something unexpected occurred" type="StandardError">
        <![CDATA[stack
trace]]>
      </failure>
    </testcase>
  </testsuite>
  <testsuite name="rspec" tests="1" failures="0" errors="0" time="1.671" timestamp="2016-01-14T14:08:12+01:00">
    <properties />
    <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
      <skipped/>
    </testcase>
  </testsuite>
</testsuites>
    EOS

    version = '1.2.3'
    payload_headers = generate_xml_payload_headers projects[0], version: version

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload, user: user, content_type: 'application/xml', headers: payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 4878, bytes: raw_payload.bytesize, endedAt: '2016-01-14T13:08:12.000Z'
    end

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3

    # check payload & report
    payload = check_payload @response_body, rawContents: raw_payload,
                            testsCount: 3, newTestsCount: 3,
                            resultsCount: 3, passedResultsCount: 2, inactiveResultsCount: 1, inactivePassedResultsCount: 1

    check_report payload, organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: version, projectId: projects[0].api_id

    # check the 3 new tests
    tests = check_tests projects[0], user, payload do
      check_test name: 'It should work'
      check_test name: 'It might work'
      check_test name: 'It could work'
    end

    # check the 3 results
    raw_results = [
      { n: 'It should work', d: 3 },
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, v: false }
    ]

    results = check_results raw_results, payload do
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[2], newTest: true
    end

    # check the descriptions of the 3 tests for the project version
    check_descriptions payload, tests do
      check_description results[0], resultsCount: 1
      check_description results[1], resultsCount: 1, passing: false
      check_description results[2], resultsCount: 1, active: false
    end
  end

  it "should combine payloads based on the test report uid", probedock: { key: 'mlcm' } do

    # prepare 2 payloads
    first_raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="1" failures="0" errors="0" time="1.2078" timestamp="2016-01-14T14:08:09+01:00">
  <properties />
  <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
</testsuite>
    EOS

    second_raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="cucumber" tests="2" failures="1" errors="0" time="0.305392" timestamp="2016-01-14T14:08:12+01:00">
  <properties />
  <testcase classname="spec.models.b_spec" name="It might work" file="./spec/models/b_spec.rb" time="0.050373">
    <failure message="something unexpected occurred" type="StandardError">
      <![CDATA[stack
trace]]>
    </failure>
  </testcase>
  <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
    <skipped/>
  </testcase>
</testsuite>
    EOS

    version = '1.2.3'
    first_payload_headers = generate_xml_payload_headers projects[0], version: version, uid: 'foo', category: 'RSpec'
    second_payload_headers = generate_xml_payload_headers projects[0], version: version, uid: 'foo', category: 'Cucumber'

    store_preaction_state

    # publish the 2 payloads
    with_resque do
      api_post '/api/publish', first_raw_payload, user: user, content_type: 'application/xml', headers: first_payload_headers
      expect_http_status_code 202
      @first_response_body = @response_body
      check_payload_response @response_body, projects[0], user, version: version, duration: 1208, bytes: first_raw_payload.bytesize, endedAt: '2016-01-14T13:08:09.000Z'

      api_post '/api/publish', second_raw_payload, user: user, content_type: 'application/xml', headers: second_payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 305, bytes: second_raw_payload.bytesize, endedAt: '2016-01-14T13:08:12.000Z'
    end

    # check payloads
    first_payload = check_payload @first_response_body, rawContents: first_raw_payload,
                                  testsCount: 1, newTestsCount: 1, resultsCount: 1, passedResultsCount: 1,
                                  categories: [ 'RSpec' ]

    second_payload = check_payload @response_body, rawContents: second_raw_payload,
                                   testsCount: 2, newTestsCount: 2,
                                   resultsCount: 2, passedResultsCount: 1, inactiveResultsCount: 1, inactivePassedResultsCount: 1,
                                   categories: [ 'Cucumber' ]

    # check database changes
    expect_changes test_payloads: 2, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3, categories: 2

    # check report
    check_report first_payload, second_payload, uid: 'foo', organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: '1.2.3', projectId: projects[0].api_id

    # check the 3 new tests
    tests = check_tests projects[0], user, first_payload do
      check_test name: 'It should work'
    end

    tests += check_tests(projects[0], user, second_payload) do
      check_test name: 'It might work'
      check_test name: 'It could work'
    end

    # check the result of the first payload
    raw_results = [
      { n: 'It should work', d: 3, p: true }
    ]

    results = check_results raw_results, first_payload do
      check_result test: tests[0], newTest: true
    end

    # check the 2 results of the second payload
    raw_results = [
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, p: true, v: false }
    ]

    results += check_results raw_results, second_payload do
      check_result test: tests[1], newTest: true
      check_result test: tests[2], newTest: true
    end

    # check the descriptions of the first test for the first payload's project version
    check_descriptions first_payload, tests[0, 1] do
      check_description results[0], resultsCount: 1, category: 'RSpec'
    end

    # check the descriptions of the two other tests for the second payload's project version
    check_descriptions second_payload, tests[1, 2] do
      check_description results[1], resultsCount: 1, passing: false, category: 'Cucumber'
      check_description results[2], resultsCount: 1, active: false, category: 'Cucumber'
    end
  end

  it "should associate results with existing tests", probedock: { key: '9q52' } do

    tests = []

    v1 = create :project_version, project: projects[0], name: '1.1.2'
    tests << create(:test, name: 'It should work', project: projects[0], last_runner: user, project_version: v1, first_run_at: Time.parse('2015-01-01'))

    v2 = create :project_version, project: projects[0], name: '1.2.3'
    k1 = create :test_key, user: user, project: projects[0]
    tests << create(:test, name: 'It might work', project: projects[0], key: k1, last_runner: user, project_version: v2, first_run_at: Time.parse('2015-01-01'))
    tests << create(:test, name: 'It worked', project: projects[0], last_runner: user, project_version: v2, first_run_at: Time.parse('2015-01-01'))

    v3 = create :project_version, project: projects[1], name: '1.3.4'
    create :test, name: 'It should work', project: projects[1], last_runner: user, project_version: v3, first_run_at: Time.parse('2015-01-01')
    k2 = create :test_key, user: user, project: projects[1], key: k1.key
    create :test, name: 'It could work', project: projects[1], key: k2, last_runner: user, project_version: v3, first_run_at: Time.parse('2015-01-01')

    Project.where(id: projects[0].id).update_all tests_count: ProjectTest.where(project_id: projects[0].id).count

    # prepare payload
    raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="3" failures="1" errors="0" time="5.207134" timestamp="2016-01-14T14:08:09+01:00">
  <properties />
  <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
  <testcase classname="spec.models.b_spec" name="It might work" file="./spec/models/b_spec.rb" time="0.050373">
    <failure message="something unexpected occurred" type="StandardError">
      <![CDATA[stack
trace]]>
    </failure>
  </testcase>
  <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
    <skipped/>
  </testcase>
  <testcase classname="spec.models.a_spec" name="It should work" file="./spec/models/a_spec.rb" time="0.01204"/>
  <testcase classname="spec.models.d_spec" name="It worked" file="./spec/models/d_spec.rb" time="2.51953"/>
</testsuite>
    EOS

    version = '1.3.4'
    payload_headers = generate_xml_payload_headers projects[0], version: version

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload, user: user, content_type: 'application/xml', headers: payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 5207, bytes: raw_payload.bytesize, endedAt: '2016-01-14T13:08:09.000Z'
    end

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 5, project_versions: 1, project_tests: 1, test_descriptions: 4

    # check payload & report
    payload = check_payload @response_body, rawContents: raw_payload,
                            testsCount: 4, newTestsCount: 1,
                            resultsCount: 5, passedResultsCount: 4, inactiveResultsCount: 1, inactivePassedResultsCount: 1

    check_report payload, organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(4)
    expect_project_version name: version, projectId: projects[0].api_id

    # check the 3 existing tests and the new test
    tests = check_tests projects[0], user, payload do
      check_test name: 'It should work', resultsCount: 2, test: tests[0]
      check_test name: 'It might work', key: k1.key, resultsCount: 1, test: tests[1]
      check_test name: 'It could work', resultsCount: 1
      check_test name: 'It worked', resultsCount: 1, test: tests[2]
    end

    # check the 5 results
    raw_results = [
      { n: 'It should work', d: 3 },
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, v: false },
      { n: 'It should work', d: 12 },
      { n: 'It worked', d: 2520 }
    ]

    results = check_results raw_results, payload do
      check_result test: tests[0], newTest: false
      check_result test: tests[1], newTest: false
      check_result test: tests[2], newTest: true
      check_result test: tests[0], newTest: false
      check_result test: tests[3], newTest: false
    end

    # check the descriptions of the 4 tests for the project version
    check_descriptions payload, tests do
      check_description results[3], resultsCount: 2
      check_description results[1], resultsCount: 1, passing: false
      check_description results[2], resultsCount: 1, active: false
      check_description results[4], resultsCount: 1
    end
  end

  it "should process a payload with leading or trailing spaces in test names", probedock: { key: 'b3z7' } do

    tests = []

    v1 = create :project_version, project: projects[0], name: '1.1.2'
    tests << create(:test, name: 'It should work', project: projects[0], last_runner: user, project_version: v1, first_run_at: Time.parse('2015-01-01'))

    v2 = create :project_version, project: projects[0], name: '1.2.3'
    k1 = create :test_key, user: user, project: projects[0]
    tests << create(:test, name: 'It might work', project: projects[0], key: k1, last_runner: user, project_version: v2, first_run_at: Time.parse('2015-01-01'))
    tests << create(:test, name: 'It worked', project: projects[0], last_runner: user, project_version: v2, first_run_at: Time.parse('2015-01-01'))

    v3 = create :project_version, project: projects[1], name: '1.3.4'
    create :test, name: 'It should work', project: projects[1], last_runner: user, project_version: v3, first_run_at: Time.parse('2015-01-01')
    k2 = create :test_key, user: user, project: projects[1], key: k1.key
    create :test, name: 'It could work', project: projects[1], key: k2, last_runner: user, project_version: v3, first_run_at: Time.parse('2015-01-01')

    Project.where(id: projects[0].id).update_all tests_count: ProjectTest.where(project_id: projects[0].id).count

    # prepare payload
    raw_payload = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="rspec" tests="3" failures="1" errors="0" time="5.207134" timestamp="2016-01-14T14:08:09+01:00">
  <properties />
  <testcase classname="spec.models.a_spec" name="  It should work" file="./spec/models/a_spec.rb" time="0.003033"/>
  <testcase classname="spec.models.b_spec" name="It might work  " file="./spec/models/b_spec.rb" time="0.050373">
    <failure message="something unexpected occurred" type="StandardError">
      <![CDATA[stack
trace]]>
    </failure>
  </testcase>
  <testcase classname="spec.models.c" name="It could work" file="./spec/models/c_spec.rb" time="0.000015">
    <skipped/>
  </testcase>
  <testcase classname="spec.models.a_spec" name="It should work " file="./spec/models/a_spec.rb" time="0.01204"/>
  <testcase classname="spec.models.d_spec" name="It worked" file="./spec/models/d_spec.rb" time="2.51953"/>
</testsuite>
    EOS

    version = '1.3.4'
    payload_headers = generate_xml_payload_headers projects[0], version: version

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload, user: user, content_type: 'application/xml', headers: payload_headers
      expect_http_status_code 202
      check_payload_response @response_body, projects[0], user, version: version, duration: 5207, bytes: raw_payload.bytesize, endedAt: '2016-01-14T13:08:09.000Z'
    end

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 5, project_versions: 1, project_tests: 1, test_descriptions: 4

    # check payload & report
    payload = check_payload @response_body, rawContents: raw_payload,
                            testsCount: 4, newTestsCount: 1,
                            resultsCount: 5, passedResultsCount: 4, inactiveResultsCount: 1, inactivePassedResultsCount: 1

    check_report payload, organization: organization

    # check project & version
    expect(projects[0].tap(&:reload).tests_count).to eq(4)
    expect_project_version name: version, projectId: projects[0].api_id

    # check the 3 existing tests and the new test
    tests = check_tests projects[0], user, payload do
      check_test name: 'It should work', resultsCount: 2, test: tests[0]
      check_test name: 'It might work', key: k1.key, resultsCount: 1, test: tests[1]
      check_test name: 'It could work', resultsCount: 1
      check_test name: 'It worked', resultsCount: 1, test: tests[2]
    end

    # check the 5 results
    raw_results = [
      { n: 'It should work', d: 3 },
      { n: 'It might work', d: 50, p: false, m: "StandardError\nstack\ntrace" },
      { n: 'It could work', d: 0, v: false },
      { n: 'It should work', d: 12 },
      { n: 'It worked', d: 2520 }
    ]

    results = check_results raw_results, payload do
      check_result test: tests[0], newTest: false
      check_result test: tests[1], newTest: false
      check_result test: tests[2], newTest: true
      check_result test: tests[0], newTest: false
      check_result test: tests[3], newTest: false
    end

    # check the descriptions of the 4 tests for the project version
    check_descriptions payload, tests do
      check_description results[3], resultsCount: 2
      check_description results[1], resultsCount: 1, passing: false
      check_description results[2], resultsCount: 1, active: false
      check_description results[4], resultsCount: 1
    end
  end
end

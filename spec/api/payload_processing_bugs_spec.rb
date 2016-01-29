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

RSpec.describe 'Payload processing' do
  include PayloadProcessingSpecHelper

  let(:organization){ create :organization }
  let!(:project){ create :project, organization: organization }
  let!(:user){ create :org_member, organization: organization }

  it "should add similarly named results to the first one of those results that has a key", probedock: { key: 'gq5p' } do

    tests = []

    Project.where(id: project.id).update_all tests_count: ProjectTest.where(project_id: project.id).count

    raw_payload = generate_raw_payload project, version: '1.2.3', results: [
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing', k: 'foo' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam', k: 'bar' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien', k: 'foo' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien' },
      { n: 'Lorem ipsum dolor sit', k: 'bar' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus', k: 'foo' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus' },
      { n: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien', k: 'bar' }
    ]

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload.to_json, user: user
      expect_http_status_code 202
      check_json_payload_response @response_body, project, user, raw_payload
    end

    # check payload & report
    payload = check_json_payload @response_body, raw_payload, testsCount: 2, newTestsCount: 2
    check_report payload, organization: organization

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 10, project_versions: 1, project_tests: 2, test_keys: 2, test_descriptions: 2

    # check project & version
    expect(project.tap(&:reload).tests_count).to eq(2)
    expect_project_version name: raw_payload[:version], projectId: project.api_id

    # check the 2 new tests
    tests = check_tests project, user, payload do
      check_test key: 'foo', name: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus', resultsCount: 6
      check_test key: 'bar', name: 'Lorem ipsum dolor sit amet consectetuer adipiscing elit proin risus praesent lectus vestibulum quam sapien', resultsCount: 4
    end

    # check the 10 results
    results = check_results raw_payload[:results], payload do
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[0], newTest: true
      check_result test: tests[0], newTest: true
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[1], newTest: true
      check_result test: tests[0], newTest: true
      check_result test: tests[0], newTest: true
      check_result test: tests[1], newTest: true
    end

    # check the descriptions of the 2 tests for the payload's project version
    check_descriptions payload, tests do
      check_description results[8], resultsCount: 6
      check_description results[9], resultsCount: 4
    end
  end

  it "should add similarly named results to the same existing test as the first one of those results that has a key", probedock: { key: 'df2m' } do

    tests = []

    version = create :project_version, project: project, name: '1.2.3'
    tests << create(:test, name: 'It should work', project: project, last_runner: user, project_version: version)
    k1 = create :test_key, user: user, project: project
    tests << create(:test, name: 'It might work', project: project, key: k1, last_runner: user, project_version: version)
    k2 = create :test_key, user: user, project: project
    tests << create(:test, name: 'It could work', project: project, key: k2, last_runner: user, project_version: version)

    Project.where(id: project.id).update_all tests_count: ProjectTest.where(project_id: project.id).count

    raw_payload = generate_raw_payload project, version: '1.2.3', results: [
      { n: 'It should work' },
      { n: 'It should work' },
      { n: 'It should work', k: k1.key },
      { n: 'It should work' },
      { n: 'It should work', k: k2.key },
      { n: 'It should work' }
    ]

    store_preaction_state

    # publish payload
    with_resque do
      api_post '/api/publish', raw_payload.to_json, user: user
      expect_http_status_code 202
      check_json_payload_response @response_body, project, user, raw_payload
    end

    # check payload & report
    payload = check_json_payload @response_body, raw_payload, testsCount: 2, newTestsCount: 0
    check_report payload, organization: organization

    # check database changes
    expect_changes test_payloads: 1, test_reports: 1, test_results: 6

    # check project & version
    expect(project.tap(&:reload).tests_count).to eq(3)
    expect_project_version name: raw_payload[:version], projectId: project.api_id

    # check the 2 new tests
    tests = check_tests project, user, payload do
      check_test key: k1.key, name: 'It should work', resultsCount: 5, test: tests[1]
      check_test key: k2.key, name: 'It should work', resultsCount: 1, test: tests[2]
    end

    # check the 10 results
    results = check_results raw_payload[:results], payload do
      check_result test: tests[0], newTest: false
      check_result test: tests[0], newTest: false
      check_result test: tests[0], newTest: false
      check_result test: tests[0], newTest: false
      check_result test: tests[1], newTest: false
      check_result test: tests[0], newTest: false
    end

    # check the descriptions of the 2 tests for the payload's project version
    check_descriptions payload, tests do
      check_description results[5], resultsCount: 5
      check_description results[4], resultsCount: 1
    end
  end
end

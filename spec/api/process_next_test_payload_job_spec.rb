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

RSpec.describe ProcessNextTestPayloadJob do
  let(:organization){ create :organization }
  let!(:projects){ Array.new(2){ create :project, organization: organization } }
  let!(:user){ create :org_member, organization: organization }

  it "should process a simple payload", probedock: { key: 'rbzu' } do

    raw_payload = {
      projectId: projects[0].api_id,
      version: '1.0.0',
      duration: 2345,
      results: [
        {
          n: 'It should work',
          p: true,
          d: 124
        },
        {
          n: 'It might work',
          p: false,
          d: 31,
          m: 'Oops'
        },
        {
          n: 'It should also work',
          p: true,
          d: 1584
        }
      ]
    }

    store_preaction_state

    with_resque do
      api_post '/api/publish', raw_payload.to_json, user: user

      expect(response.status).to eq(202)
      expect_json @response_body, {
        receivedAt: '@iso8601',
        payloads: [
          {
            id: '@alphanumeric',
            bytes: MultiJson.dump(raw_payload).bytesize
          }
        ]
      }
    end

    expect_changes test_payloads: 1, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3

    payload = expect_test_payload @response_body.merge({
      state: :processed,
      resultsCount: 3,
      passedResultsCount: 2,
      testsCount: 3,
      newTestsCount: 3
    })

    expect_test_report({
      id: TestReport.last.api_id,
      organizationId: organization.api_id,
      startedAt: payload.started_at.iso8601(3),
      endedAt: payload.ended_at.iso8601(3),
      payloadIds: [ payload.api_id ]
    })

    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: '1.0.0', projectId: projects[0].api_id

    tests = []
    [ "It should work", "It might work", "It should also work" ].each do |name|
      tests << expect_test(projectId: projects[0].api_id, name: name, resultsCount: 1, firstRunAt: payload.ended_at.iso8601(3), firstRunnerId: user.api_id)
    end

    raw_payload[:results].each.with_index do |result,i|
      expect_test_result payloadId: payload.api_id, testId: tests[i].api_id, name: result[:n], passed: result[:p], message: result[:m], newTest: true, duration: result[:d]
    end
  end

  it "should combine payloads based on the test report uid", probedock: { key: '9otz' } do

    raw_first_payload = {
      projectId: projects[0].api_id,
      version: '1.0.0',
      duration: 200,
      results: [
        {
          n: 'It should work',
          p: true,
          d: 124
        }
      ],
      reports: [
        { uid: 'foo' }
      ]
    }

    raw_second_payload = {
      projectId: projects[0].api_id,
      version: '1.0.0',
      duration: 1826,
      results: [
        {
          n: 'It might work',
          p: false,
          d: 31,
          m: 'Oops'
        },
        {
          n: 'It should also work',
          p: true,
          d: 1584
        }
      ],
      reports: [
        { uid: 'foo' }
      ]
    }

    store_preaction_state

    with_resque do
      api_post '/api/publish', raw_first_payload.to_json, user: user

      expect(response.status).to eq(202)
      @first_response_body = @response_body
      expect_json @response_body, {
        receivedAt: '@iso8601',
        payloads: [
          {
            id: '@alphanumeric',
            bytes: MultiJson.dump(raw_first_payload).bytesize
          }
        ]
      }

      api_post '/api/publish', raw_second_payload.to_json, user: user

      expect(response.status).to eq(202)
      expect_json @response_body, {
        receivedAt: '@iso8601',
        payloads: [
          {
            id: '@alphanumeric',
            bytes: MultiJson.dump(raw_first_payload).bytesize
          }
        ]
      }
    end

    expect_changes test_payloads: 2, test_reports: 1, test_results: 3, project_versions: 1, project_tests: 3, test_descriptions: 3

    first_payload = expect_test_payload @first_response_body.merge({
      state: :processed,
      resultsCount: 1,
      passedResultsCount: 1,
      testsCount: 1,
      newTestsCount: 1
    })

    second_payload = expect_test_payload @response_body.merge({
      state: :processed,
      resultsCount: 2,
      passedResultsCount: 1,
      testsCount: 2,
      newTestsCount: 2
    })

    expect_test_report({
      id: TestReport.last.api_id,
      uid: 'foo',
      organizationId: organization.api_id,
      startedAt: second_payload.started_at.iso8601(3),
      endedAt: second_payload.ended_at.iso8601(3),
      payloadIds: [ first_payload.api_id, second_payload.api_id ]
    })

    expect(projects[0].tap(&:reload).tests_count).to eq(3)
    expect_project_version name: '1.0.0', projectId: projects[0].api_id

    tests = []
    [ "It should work" ].each do |name|
      tests << expect_test(projectId: projects[0].api_id, name: name, resultsCount: 1, firstRunAt: first_payload.ended_at.iso8601(3), firstRunnerId: user.api_id)
    end

    [ "It might work", "It should also work" ].each do |name|
      tests << expect_test(projectId: projects[0].api_id, name: name, resultsCount: 1, firstRunAt: second_payload.ended_at.iso8601(3), firstRunnerId: user.api_id)
    end

    raw_first_payload[:results].each.with_index do |result,i|
      expect_test_result payloadId: first_payload.api_id, testId: tests[i].api_id, name: result[:n], passed: result[:p], message: result[:m], newTest: true, duration: result[:d]
    end

    raw_second_payload[:results].each.with_index do |result,i|
      expect_test_result payloadId: second_payload.api_id, testId: tests[i + raw_first_payload[:results].length].api_id, name: result[:n], passed: result[:p], message: result[:m], newTest: true, duration: result[:d]
    end
  end
end

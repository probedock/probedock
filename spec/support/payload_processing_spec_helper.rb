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
module PayloadProcessingSpecHelper
  def check_descriptions payload, tests, options = {}
    @description_check_payload = payload
    @description_check_tests = tests
    @description_check_descriptions = []

    yield if block_given?

    @description_check_payload = nil
    @description_check_tests = nil

    descriptions = @description_check_descriptions
    @description_check_descriptions = nil

    descriptions
  end

  def check_description last_result, options = {}

    index = @description_check_descriptions.length
    test = @description_check_tests[index]
    project_version = @description_check_payload.project_version

    expectations = options.reverse_merge({
      testId: test.api_id,
      projectVersion: project_version.name,
      name: last_result.name,
      category: last_result.category.try(&:name),
      tags: last_result.tags.try(:collect, &:name).sort,
      tickets: last_result.tickets.try(:collect, &:name).sort,
      lastDuration: last_result.duration,
      lastRunAt: last_result.run_at,
      lastRunnerId: last_result.runner.api_id,
      lastResultId: last_result.id,
      contributions: options.fetch(:contributions, [])
    })

    unless options.key? :contributions
      if test.key.try(:user).try(:human?)
        expectations[:contributions] << { kind: :key_creator, userId: test.key.user.api_id }
      elsif test.first_runner.try(:human?)
        expectations[:contributions] << { kind: :first_runner, userId: test.first_runner.api_id }
      end
    end

    description = expect_test_description expectations
    @description_check_descriptions << description
    description
  end

  def check_results raw_results, payload, options = {}
    @result_check_raw_results = raw_results
    @result_check_payload = payload
    @result_check_results = []

    yield if block_given?

    @result_check_raw_results = nil
    @result_check_payload = nil

    results = @result_check_results
    @result_check_results = nil

    results
  end

  def check_result options = {}

    index = @result_check_results.length
    raw_result = @result_check_raw_results[index]

    expectations = options.reverse_merge({
      payloadId: @result_check_payload.api_id,
      payloadIndex: index,
      testId: options[:test].try(:api_id),
      passed: raw_result.fetch(:p, true),
      active: raw_result.fetch(:v, true),
      name: raw_result[:n],
      duration: raw_result[:d],
      message: raw_result[:m],
      newTest: false
    })

    result = expect_test_result expectations
    @result_check_results << result
    result
  end

  def check_tests project, runner, payload
    @test_check_project = project
    @test_check_runner = runner
    @test_check_payload = payload
    @test_check_tests = []

    yield if block_given?

    @test_check_project = nil
    @test_check_runner = nil
    @test_check_payload = nil

    tests = @test_check_tests
    @test_check_tests = nil

    tests
  end

  def check_test options = {}
    expectations = {
      projectId: @test_check_project.api_id,
      name: options[:name],
      key: options[:key],
      resultsCount: options.fetch(:resultsCount, 1)
    }

    expectations[:firstRunAt] = if options[:firstRunAt]
      options[:firstRunAt]
    elsif options[:test]
      options[:test].first_run_at.iso8601(3)
    else
      @test_check_payload.ended_at.iso8601(3)
    end

    expectations[:firstRunnerId] = if options[:firstRunnerId]
      options[:firstRunnerId]
    elsif options[:test]
      options[:test].first_runner.try :api_id
    else
      @test_check_runner.api_id
    end

    test = expect_test expectations
    @test_check_tests << test

    test
  end

  def check_report *args
    options = args.extract_options!
    payloads = args

    expectations = {
      id: options[:id] || TestReport.last.api_id,
      organizationId: options[:organizationId] || options[:organization].try(:api_id),
      startedAt: payloads.sort{ |a,b| a.started_at <=> b.started_at }.first.started_at.iso8601(3),
      endedAt: payloads.sort{ |a,b| a.ended_at <=> b.ended_at }.last.ended_at.iso8601(3),
      payloadIds: payloads.collect(&:api_id)
    }

    expectations[:uid] = options[:uid] if options.key? :uid

    expect_test_report expectations
  end

  def check_json_payload body, raw_payload, options = {}
    check_payload body, options.merge({
      resultsCount: raw_payload[:results].length,
      passedResultsCount: raw_payload[:results].select{ |r| r.fetch :p, true }.length,
      inactiveResultsCount: raw_payload[:results].reject{ |r| r.fetch :v, true }.length,
      inactivePassedResultsCount: raw_payload[:results].select{ |r| r.fetch(:p, true) && !r.fetch(:v, true) }.length
    })
  end

  def check_payload body, options = {}

    expectations = body.with_indifferent_access.slice :receivedAt
    expectations.merge! body['payloads'][0] if body['payloads'].length == 1

    expect_test_payload expectations.merge({
      state: :processed,
      resultsCount: options.fetch(:resultsCount, 0),
      passedResultsCount: options.fetch(:passedResultsCount, 0),
      inactiveResultsCount: options.fetch(:inactiveResultsCount, 0),
      inactivePassedResultsCount: options.fetch(:inactivePassedResultsCount, 0),
      testsCount: options.fetch(:testsCount, 0),
      newTestsCount: options.fetch(:newTestsCount, 0),
      rawContents: options[:rawContents]
    })
  end

  def check_json_payload_response body, project, runner, raw_payload
    check_payload_response body, project, runner, raw_payload.merge(bytes: MultiJson.dump(raw_payload).bytesize)
  end

  def check_payload_response body, project, runner, options = {}
    expect_json body, {
      receivedAt: '@iso8601',
      payloads: [
        {
          id: '@uuid',
          projectId: project.api_id,
          projectVersion: options[:version],
          duration: options[:duration],
          runnerId: runner.api_id,
          endedAt: options.fetch(:endedAt, '@json(/receivedAt)'),
          bytes: options[:bytes]
        }
      ]
    }
  end

  def generate_xml_payload_headers project, options = {}
    h = {
      'Probe-Dock-Project-Id' => project.api_id,
      'Probe-Dock-Project-Version' => options[:version] || random_project_version
    }

    h['Probe-Dock-Category'] = options[:category] if options[:category]
    h['Probe-Dock-Test-Report-Uid'] = options[:uid] if options[:uid]

    h
  end

  def generate_raw_payload project, options = {}

    raw_payload = {
      projectId: project.api_id,
      version: options[:version] || random_project_version,
      results: []
    }

    options[:results].each do |r|
      result = {
        n: r[:n],
        p: r.fetch(:p, true),
        d: r[:d] || rand(1000)
      }

      %i(k m c g t a).each do |attr|
        result[attr] = r[attr] if r.key? attr
      end

      result[:m] ||= "bug #{rand(1000)}" unless result[:p]

      raw_payload[:results] << result
    end

    raw_payload[:duration] = options[:duration] || (raw_payload[:results].inject(0){ |memo,r| memo + r[:d] } + rand(250))
    raw_payload[:reports] = [ { uid: options[:uid] } ] if options[:uid]

    raw_payload
  end

  private

  def random_project_version
    "#{rand(10)}.#{rand(20)}.#{rand(10)}"
  end
end

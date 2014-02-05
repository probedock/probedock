# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
class Api::PayloadsController < Api::ApiController
  before_filter :check_maintenance, only: :create
  before_filter(only: :create){ check_content_type :rox_payload_v1 }

  def create

    time_received = Time.now

    body = parse_payload request.body.read, time_received
    json = parse_json_request_body body
    validate_payload json

    payload = TestPayload.new(contents: body, user: current_api_user, received_at: time_received).tap(&:save!)

    Resque.enqueue ProcessNextTestPayloadJob
    $api_logger.info "Accepted payload for processing in #{((Time.now - time_received) * 1000).round}ms"

    head :accepted # HTTP 202 (accepted for processing)
  end

  private

  def parse_payload raw_body, time_received

    original_size = raw_body.bytesize
    $api_logger.info "\nStarted processing payload (#{original_size} bytes) at #{time_received}"

    body = ensure_json_encoding raw_body

    $payload_logger.info "\nPayload received at #{time_received}"
    $payload_logger.info body

    body
  end

  def validate_payload json

    fail :invalidValue, "Payload must be an object, got #{sc json}", '' if !json.kind_of?(Hash)

    run = HashWithIndifferentAccess.new json

    fail :missingKey, "Test run duration is missing", "/d" if !run.key?(:d)
    fail :invalidValue, "Test run duration must be a number of milliseconds, got #{s run[:d]}", "/d" if !run[:d].kind_of?(Fixnum) or run[:d] < 0

    check_string run, :u, "Test run UID", "/u", 255, required: false
    if run.key? :u
      test_run = TestRun.where(uid: run[:u]).first
      fail :forbiddenTestRunUid, "Test run was created by another user", "/u" if test_run and current_api_user != test_run.runner
    end

    check_string run, :g, "Test run group", "/g", 255, required: false

    check_array run, :r, "Test run results", "/r"

    projects = []

    run[:r].each_with_index do |results,i|

      fail :invalidValue, "Results must be an object, got #{sc json}", "/r/#{i}" if !results.kind_of?(Hash)

      check_string results, :j, "Results project", "/r/#{i}/j", 255
      fail :duplicateProject, "Results project #{s results[:j]} was already used in this run", "/r/#{i}/j" if projects.include? results[:j]
      projects << results[:j]

      check_string results, :v, "Results project version", "/r/#{i}/v", 255

      check_array results, :t, "Results test results", "/r/#{i}/t"

      results[:t].each_with_index do |test, j|

        fail :invalidValue, "Test must be an object, got #{sc test}", "/r/#{i}/t/#{j}" if !test.kind_of?(Hash)
        fail :missingKey, "Test key for test #{st test} is missing", "/r/#{i}/t/#{j}/k" if !test.key?(:k)
        fail :invalidValue, "Test key must be 12 alphanumeric characters, got #{s test[:k]}", "/r/#{i}/t/#{j}/k" if !test[:k].kind_of?(String) or !test[:k].match(/\A[a-z0-9]{12}\Z/i)
      end
    end

    # If the test run has an UID, find all test keys that have already been used.
    used_keys = if run[:u]
      TestKey.select('test_keys.key, projects.api_id AS project_api_id').joins([ :project, { test_info: { results: :test_run } }]).where('test_runs.uid = ?', run[:u]).to_a
    else
      []
    end

    # Find all test keys in the payload.
    keys_by_project = run[:r].inject({}){ |memo,r| memo[r[:j]] = r[:t].collect{ |t| t[:k] }; memo }
    existing_keys = TestKey.for_projects_and_keys(keys_by_project).select('test_keys.key, test_keys.free, projects.api_id AS project_api_id').to_a

    unfree_keys = existing_keys.reject(&:free?)

    keys = {}

    run[:r].each_with_index do |results,i|
      project = results[:j]
      keys[project] ||= []

      results[:t].each_with_index do |test,j|
        key = test[:k]

        fail :duplicateTestKey, "Test key #{s key} (project #{s project}) was already used in a previous payload for this run", "/r/#{i}/t/#{j}/k" if find_key used_keys, project, key
        fail :duplicateTestKey, "Test key #{s key} (project #{s project}) was already used in this run", "/r/#{i}/t/#{j}/k" if keys[project].include? key
        fail :unknownTestKey, "Test key #{s key} (project #{s project}) is unknown", "/r/#{i}/t/#{j}/k" if !find_key(existing_keys, project, key)
        keys[project] << key
      end
    end

    run[:r].each_with_index do |results,i|

      results[:t].each_with_index do |test,j|

        test_exists = find_key(unfree_keys, results[:j], test[:k])
        
        check_string test, :n, "Test name for test #{st test}", "/r/#{i}/t/#{j}/n", 255, required: !test_exists

        fail :missingKey, "Test passed status is missing for test #{st test}", "/r/#{i}/t/#{j}/p" if !test.key?(:p)
        fail :invalidValue, "Test passed status must be a boolean, got #{sc test[:p]} for test #{st test}", "/r/#{i}/t/#{j}/p" if !!test[:p] != test[:p]

        check_string test, :c, "Test category for test #{st test}", "/r/#{i}/t/#{j}/c", 255 if test.key?(:c) and !test[:c].nil?

        if test.key?(:f)
          fail :invalidValue, "Test flags must be an integer bitmask greater than or equal to zero, got #{s test[:f]} for test #{st test}", "/r/#{i}/t/#{j}/f" if !test[:f].kind_of?(Fixnum) or test[:f] < 0
        end

        # check test tags
        tags = test[:g]
        check_array test, :g, "Test tags for test #{st test}", "/r/#{i}/t/#{j}/g", required: false
        if tags.present?
          tags.each_with_index do |name,k|

            check_string tags, k, "Test tag for test #{st test}", "/r/#{i}/t/#{j}/g/#{k}", 50
            fail :invalidValue, "Test tag must contain only alphanumeric characters, hyphens and underscores, got #{s name} for test #{st test}", "/r/#{i}/t/#{j}/g/#{k}" if !name.match(Tag::NAME_REGEXP)
          end
        end

        tickets = test[:t]
        check_array test, :t, "Test tickets for test #{st test}", "/r/#{i}/t/#{j}/t", required: false
        if tickets.present?
          tickets.each_with_index do |name,k|

            check_string tickets, k, "Test ticket for test #{st test}", "/r/#{i}/t/#{j}/t/#{k}", 255
          end
        end

        # check result duration
        fail :missingKey, "Test duration is missing for test #{st test}", "/r/#{i}/t/#{j}/d" if !test.key?(:d)
        fail :invalidValue, "Test duration must be a number of milliseconds, got #{s test[:d]} for test #{st test}", "/r/#{i}/t/#{j}/d" if !test[:d].kind_of?(Fixnum) or test[:d] < 0

        check_string test, :m, "Test message for test #{st test}", "/r/#{i}/t/#{j}/m", 65535, required: false, bytesize: true

        if test.key?(:a)
          fail :invalidValue, "Test data must be an object, got #{sc test[:a]} for test #{st test}", "/r/#{i}/t/#{j}/a" if !test[:a].kind_of?(Hash)
          test[:a].each_pair do |name,value|

            fail :blankValue, "Test data name for test #{st test} must not be blank", "/r/#{i}/t/#{j}/a" if name.blank?
            fail :keyTooLong, "Test data name for test #{st test} must not be longer than 50 characters, got #{name.to_s.length}", "/r/#{i}/t/#{j}/a" if name.length > 50
            fail :invalidValue, "Test data value for test #{st test} must be a string, got #{sc value}", "/r/#{i}/t/#{j}/a" if !value.kind_of?(String)
            fail :valueTooLong, "Test data value for test #{st test} must not be longer than 255 characters, got #{value.to_s.length}", "/r/#{i}/t/#{j}/a" if value.length > 255
          end
        end
      end
    end
  end

  def find_key keys, project_api_id, value
    keys.any?{ |k| k.project_api_id == project_api_id && k.key == value }
  end

  def check_array parent, key, description, path, options = {}

    if !parent.key?(key)
      return if options[:required] == false
      fail :missingKey, "#{description} are missing", path
    end

    value = parent[key]
    fail :invalidValue, "#{description} must be an array, got #{sc value}", path if !value.kind_of?(Array)
    fail :emptyArray, "#{description} must not be empty", path if value.empty? and options[:required] != false
  end

  def check_string parent, key, description, path, max, options = {}

    if parent.respond_to?(:key?) and !parent.key?(key)
      return if options[:required] == false
      fail :missingKey, "#{description} is missing", path
    end

    value = parent[key]
    fail :invalidValue, "#{description} must be a string, got #{sc value}", path if !value.kind_of?(String)
    fail :blankValue, "#{description} must not be blank", path if value.blank?

    if options[:bytesize]
      fail :valueTooLong, "#{description} must not be bigger than #{max} bytes, got #{value.bytesize}", path if value.bytesize > max
    else
      fail :valueTooLong, "#{description} must not be longer than #{max} characters, got #{value.length}", path if value.length > max
    end
  end

  def safe text
    return :null if text.nil?
    s = text.to_s
    s.length > 33 ? %/"#{s[0, 30]}..."/ : %/"#{s}"/
  end
  alias s safe

  def safe_test test
    if test[:k].present?
      "with key #{safe test[:k]}"
    elsif test[:n].present?
      safe test[:n]
    else
      :unknown
    end
  end
  alias st safe_test

  def safe_class o
    case o.class.name
    when Hash.name, HashWithIndifferentAccess.name
      :object
    when Array.name
      :array
    when Fixnum.name, Float.name
      :number
    when String.name
      :string
    when TrueClass.name, FalseClass.name
      :boolean
    when NilClass.name
      :null
    else
      :unknown
    end
  end
  alias sc safe_class

  def fail name, msg = 'Error', path = nil
    $api_logger.info "Refused payload due to: #{msg}"
    options = { name: name }
    options[:path] = path if path
    raise ApiError.new(msg, options)
  end
end

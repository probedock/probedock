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
module ModelExpectations
  def expect_test_result data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    result = expect_record TestResult, data do
      if data.key?(:payloadId) && data.key?(:payloadIndex)
        TestResult.joins(:test_payload).where('test_payloads.api_id = ? AND test_results.payload_index = ?', data[:payloadId].to_s, data[:payloadIndex].to_i).first
      elsif data.key?(:payloadId) && data.key?(:key)
        TestResult.joins(:key, :test_payload).where('test_payloads.api_id = ? AND test_keys.key = ?', data[:payloadId].to_s, data[:key].to_s).first
      elsif data.key?(:payloadId) && data.key?(:name)
        TestResult.joins(:test_payload).where('test_payloads.api_id = ? AND test_results.name = ?', data[:payloadId].to_s, data[:name].to_s).first
      else
        raise "Test result must be identified by payload/key or payload/name, got #{data.inspect}"
      end
    end

    @errors.compare result.name, data[:name], :name
    @errors.compare result.payload_index, data[:payloadIndex], :payload_index
    @errors.compare result.passed, data.fetch(:passed, true), :passed
    @errors.compare result.active, data.fetch(:active, true), :active
    @errors.compare result.duration, data[:duration], :duration
    @errors.compare result.new_test, data.fetch(:newTest, false), :new_test
    @errors.compare result.test.api_id, data[:testId], :test_id

    if data.key? :message
      @errors.compare result.message, data[:message], :message
    else
      @errors.ensure_blank result.message, :message
    end

    expect_no_errors
    result
  end

  def expect_test_description data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    description = expect_record TestDescription, data do
      if data.key?(:testId) && data.key?(:projectVersion)
        TestDescription.joins(:test, :project_version).where('project_tests.api_id = ? AND project_versions.name = ?', data[:testId].to_s, data[:projectVersion].to_s).first
      else
        raise "Test description must be identified by a test ID and project version, got #{data.inspect}"
      end
    end

    @errors.compare description.name, data[:name], :name
    @errors.compare description.passing, data.fetch(:passing, true), :passing
    @errors.compare description.active, data.fetch(:active, true), :active
    @errors.compare description.category, data[:category], :category
    @errors.compare description.tags.collect(&:name), data.fetch(:tags, []), :tags
    @errors.compare description.tickets.collect(&:name), data.fetch(:tickets, []), :tickets
    @errors.compare description.last_duration, data[:lastDuration], :last_duration
    @errors.compare description.last_run_at.try(:iso8601, 3), data[:lastRunAt].try(:iso8601, 3), :last_run_at
    @errors.compare description.last_runner.try(:api_id), data[:lastRunnerId], :last_runner_id
    @errors.compare description.last_result.try(:id), data[:lastResultId], :last_result_id
    @errors.compare description.results_count, data.fetch(:resultsCount, 1), :results_count
    @errors.compare description.custom_values, data.fetch(:customValues, {}), :custom_values

    expect_no_errors
    description
  end

  def expect_test data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    test = expect_record ProjectTest, data do
      if data.key? :id
        ProjectTest.where(api_id: data[:id].to_s).first
      elsif data.key?(:projectId) && data.key?(:name)
        ProjectTest.joins(:project).where('projects.api_id = ? AND project_tests.name = ?', data[:projectId].to_s, data[:name].to_s).first
      else
        raise "Project test must be identified by an ID or the combination of the project ID and name, got #{data.inspect}"
      end
    end

    @errors.compare test.name, data[:name], :name
    @errors.compare test.key.try(:key), data[:key], :key
    @errors.compare test.project.api_id, data[:projectId], :project_id
    @errors.compare test.results_count, data.fetch(:resultsCount, 0), :results_count
    @errors.compare test.first_run_at.try(:iso8601, 3), data[:firstRunAt], :first_run_at if data.key? :firstRunAt
    @errors.compare test.first_runner.try(:api_id), data[:firstRunnerId], :first_runner_id if data.key? :firstRunnerId

    expect_no_errors
    test
  end

  def expect_test_report data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    report = expect_record TestReport, data

    @errors.compare report.organization.api_id, data[:organizationId], :organization_id
    @errors.compare report.started_at.iso8601(3), data[:startedAt], :started_at if data.key? :startedAt
    @errors.compare report.ended_at.iso8601(3), data[:endedAt], :ended_at if data.key? :endedAt
    @errors.compare report.test_payloads.collect(&:api_id).sort, data[:payloadIds].try(:sort), :payload_ids

    if data.key? :uid
      @errors.compare report.uid, data[:uid], :uid
    else
      @errors.ensure_blank report.uid, :uid
    end

    expect_no_errors
    report
  end

  def expect_test_payload data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    payload = expect_record TestPayload, data

    @errors.compare payload.state.to_s, data.fetch(:state, :created).to_s, :state
    @errors.compare payload.duration, data[:duration], :duration
    @errors.compare payload.runner.api_id, data[:runnerId], :runner_id
    @errors.compare payload.project_version.project.api_id, data[:projectId], :project_id
    @errors.compare payload.project_version.name, data[:projectVersion], :project_version
    @errors.compare payload.ended_at.iso8601(3), data[:endedAt], :ended_at
    @errors.compare payload.received_at.iso8601(3), data[:receivedAt] || data[:endedAt], :received_at
    @errors.compare payload.results_count, data.fetch(:resultsCount, 0), :results_count
    @errors.compare payload.passed_results_count, data.fetch(:passedResultsCount, 0), :passed_results_count
    @errors.compare payload.inactive_results_count, data.fetch(:inactiveResultsCount, 0), :inactive_results_count
    @errors.compare payload.inactive_passed_results_count, data.fetch(:inactivePassedResultsCount, 0), :inactive_passed_results_count
    @errors.compare payload.tests_count, data.fetch(:testsCount, 0), :tests_count
    @errors.compare payload.new_tests_count, data.fetch(:newTestsCount, 0), :new_tests_count

    if data.key? :contents
      @errors.compare payload.contents, data[:contents].with_indifferent_access, :contents
      @errors.compare payload.contents_bytesize, MultiJson.dump(data[:contents]).bytesize, :contents_bytesize
    else
      @errors.ensure_present payload.contents, :contents
      @errors.ensure_present payload.contents_bytesize, :contents_bytesize
    end

    expect_no_errors
    payload
  end

  def expect_project_version data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    version = expect_record ProjectVersion, data do
      ProjectVersion.joins(:project).where('project_versions.name = ? AND projects.api_id = ?', data[:name].to_s, data[:projectId].to_s).first
    end

    @errors.compare version.name, data[:name], :name
    @errors.compare version.project.api_id, data[:projectId], :project_id
    @errors.compare version.created_at, data[:createdAt] if data.key? :createdAt

    expect_no_errors
    version
  end

  def expect_app_settings data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    settings = Settings::App.get
    @errors.errors << %/expected to find an instance of #{Settings::App} in the database, but it was not found/ if settings.blank?

    @errors.compare settings.user_registration_enabled, data[:userRegistrationEnabled], :user_registration_enabled
    @errors.compare settings.updated_at.iso8601(3), data[:updatedAt], :updated_at if data.key? :updatedAt

    expect_no_errors
    settings
  end

  def expect_user_registration data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    registration = expect_record UserRegistration, data do
      if data.key? :id
        UserRegistration.where(api_id: data[:id].to_s).first
      elsif data.key? :userId
        UserRegistration.joins(:user).where('users.api_id = ?', data[:userId].to_s).first
      elsif data.key? :organizationId
        UserRegistration.joins(:organization).where('organizations.api_id = ?', data[:organizationId].to_s).first
      else
        raise "User registration must be identified by ID, user ID or organization ID"
      end
    end

    @errors.compare registration.try(:user).try(:api_id), data[:userId], :user_id

    if data.key? :organizationId
      @errors.compare registration.try(:organization).try(:api_id), data[:organizationId], :organization_id
    else
      @errors.ensure_blank registration.try(:organization).try(:api_id), :organization_id
    end

    @errors.compare registration.created_at.iso8601(3), data[:createdAt] if data.key? :createdAt
    @errors.compare registration.created_at.iso8601(3), data[:updatedAt] if data.key? :updatedAt

    if data[:completed]
      @errors.compare registration.completed, true, :completed
      @errors.ensure_blank registration.otp, :otp
      @errors.ensure_blank registration.expires_at, :expires_at
      @errors.ensure_present registration.completed_at, :completed_at
      @errors.compare registration.completed_at.iso8601(3), data[:completedAt] if data.key? :completedAt
    else
      @errors.compare registration.completed, false, :completed
      @errors.ensure_present registration.otp, :otp
      @errors.ensure_present registration.expires_at, :expires_at
      @errors.ensure_blank registration.completed_at, :completed_at

      if registration.expires_at - registration.created_at < 1.week
        @errors < "expected :expires_at to be at least 1 week after :created_at, got #{registration.expires_at} (created at #{registration.created_at})"
      end
    end

    expect_no_errors
    registration
  end

  def expect_membership data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    membership = expect_record Membership, data do
      if data.key? :id
        Membership.where(api_id: data[:id].to_s).first
      elsif data.key?(:userId) && data.key?(:organizationId)
        Membership.joins(:organization, :user).where('organizations.api_id = ? AND users.api_id = ?', data[:organizationId].to_s, data[:userId].to_s).first
      else
        raise "Membership must be identified either by ID or by User and Organization ID"
      end
    end

    @errors.compare membership.try(:user).try(:api_id), data[:userId], :user_id if data.key? :userId
    @errors.compare membership.organization.api_id, data[:organizationId], :organization_id
    @errors.compare membership.roles.collect(&:to_s).sort, (data[:roles] || []).collect(&:to_s).sort, :roles

    if data.key? :organizationEmail
      @errors.compare membership.try(:organization_email).try(:address), data[:organizationEmail], :organization_email
    else
      @errors.ensure_blank membership.try(:organization_email).try(:address), :organization_email
    end

    expect_no_errors
    membership
  end

  def expect_organization data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    organization = expect_record Organization, data

    @errors.compare organization.name, data[:name], :name
    @errors.compare organization.normalized_name, data[:name].to_s.downcase, :normalized_name
    @errors.compare organization.display_name, data[:displayName], :display_name
    @errors.compare organization.active, data.fetch(:active, true), :active
    @errors.compare organization.public_access, data.fetch(:public, true), :public_access
    @errors.compare organization.projects_count, data.fetch(:projectsCount, 0), :projects_count
    @errors.compare organization.memberships_count, data.fetch(:membershipsCount, 0), :memberships_count
    @errors.compare organization.created_at.iso8601(3), data[:createdAt], :created_at if data.key? :createdAt
    @errors.compare organization.updated_at.iso8601(3), data[:updatedAt], :updated_at if data.key? :updatedAt

    expect_no_errors
    organization
  end

  def expect_user data

    @errors = Errors.new
    data = interpolate_json(data, expectations: true).with_indifferent_access

    user = expect_record User, data

    @errors.compare user.name, data[:name], :name
    @errors.compare user.technical, data.fetch(:technical, false), :technical
    @errors.compare user.memberships.first.try(:organization).try(:api_id), data[:organizationId], :organization_id if data.key? :organizationId
    @errors.compare user.active, data.fetch(:active, true), :active
    @errors.compare user.roles.to_a.collect(&:to_s).sort, data[:roles].try(:sort) || [], :roles
    @errors.compare user.created_at.iso8601(3), data[:createdAt], :created_at

    if data.key? :primaryEmail
      @errors.compare user.primary_email.address, data[:primaryEmail], :primary_email
    else
      @errors.ensure_blank user.primary_email.try(:address), :primary_email
      @errors.ensure_blank user.emails.collect{ |e| e.address }, :emails
    end

    if data.key? :emails
      @errors.compare user.emails.collect{ |e| e.address }.sort, data[:emails].sort, :emails
    end

    if data[:technical]
      @errors << %/expected user to have no password, but it has a password digest/ unless user.password_digest.nil?
      @errors << %/expected user to have exactly one membership, found #{user.memberships.length}/ unless user.memberships.length == 1
    end

    if user.primary_email.present?
      expected_state = data[:active] ? 'active' : 'inactive'
      @errors.compare user.primary_email.active, !!data[:active], "expected primary e-mail to be #{expected_state}, but it was not"
    end

    expect_no_errors
    user
  end

  private

  def expect_record model, data, &block
    record = block ? block.call : model.where(api_id: data[:id]).first
    trigger_errors %/expected to find the following #{model} in the database, but it was not found:\n\n#{JSON.pretty_generate(data)}/ if record.blank?
    record
  end

  class Errors
    attr_reader :errors

    def initialize
      @errors = []
    end

    def << error
      @errors << error
    end

    def compare actual, expected, error
      if expected.kind_of?(Regexp) && !actual.to_s.match(expected)
        error = %/expected :#{error} to match #{expected.inspect}, but got #{actual.inspect}/ if error.kind_of? Symbol
        @errors << error
        false
      elsif !expected.kind_of?(Regexp) && actual != expected
        error = %/expected :#{error} to be #{expected.inspect}, but got #{actual.inspect}/ if error.kind_of? Symbol
        @errors << error
        false
      else
        true
      end
    end

    def ensure_blank actual, error
      if actual.present?
        error = %/expected :#{error} to be blank, but got #{actual.inspect}/ if error.kind_of? Symbol
        @errors << error
        false
      else
        true
      end
    end

    def ensure_present actual, error
      if actual.blank?
        error = %/expected :#{error} to be present, but got #{actual.inspect}/ if error.kind_of? Symbol
        @errors << error
        false
      else
        true
      end
    end
  end

  def trigger_errors error
    @errors.errors << error
    expect_no_errors
  end

  def expect_no_errors
    expect(@errors.errors).to be_empty, ->{ "\n#{@errors.errors.join("\n")}\n\n" }
  end
end

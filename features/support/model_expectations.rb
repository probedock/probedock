module ModelExpectations
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

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

# The policies defined in this directory handle authorization, scoping and serialization,
# using the Pundit library: https://github.com/elabs/pundit
#
# This class is the base policy that all policy classes should inherit from.
# It denies everything by default, so sub-classes should explicitly authorize each query.
#
# When authorization is checked with `ApiAuthorizationHelper#authorize!`, the corresponding
# policy in this directory will be initialized with the current user and specified record,
# and the corresponding query method will be called (e.g. :create? if the query was :create).
# The method should simply return true if the action is authorized, false otherwise.
class ApplicationPolicy

  # Include helpers common to policies, policy scopes and policy serializers.
  include PolicyHelpers

  # The record concerned by this policy instance.
  attr_reader :record

  # Creates a policy instance for the specified user and record.
  # The user may be a `UserContext` wrapper that will be expanded
  # (see `PolicyHelpers`).
  def initialize user, record
    @user = user
    @record = record
    expand_user_context!
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  # Returns the authorized scope for the record's class (see `Scope` below).
  # The policy class must have a `Scope` sub-module defined.
  def scope
    Pundit.policy_scope! user, record.class
  end

  # Returns the serializer for the record (see `Serializer` below).
  # The policy class must have a `Serializer` sub-module defined.
  def serializer
    serializer_class = self.class::Serializer
    raise NotDefinedError, "unable to find serializer `#{self.class}::Serializer`" unless serializer_class
    serializer_class.new @user_context || @user, @record
  end

  public

  # This class scopes the data that a user is authorized to access.
  # Sub-classes should implement the `#resolve` method, which should return
  # a filtered relation depending on the user's role and permissions.
  #
  #     class ProjectPolicy
  #       class Scope
  #         def resolve
  #           if admin?
  #             scope
  #           else
  #             scope.joins(:organization).where organization: organization
  #           end
  #         end
  #       end
  #     end
  #
  #     scope = policy_scope Project
  #
  # Check out `PolicyHelpers` to see what helper methods are available.
  class Scope

    # Include helpers common to policies, policy scopes and policy serializers.
    include PolicyHelpers

    # The initial scope.
    attr_reader :scope

    # Creates a scope instance for the specified user and base scope.
    # The user may be a `UserContext` wrapper that will be expanded
    # (see `PolicyHelpers`).
    def initialize user, scope
      @user = user
      @scope = scope
      expand_user_context!
    end

    # Returns the authorized scope for the user (based on the supplied base scope).
    def resolve
      scope
    end
  end

  # This class serializes the parts of a record that a given user is authorized to see.
  # Sub-classes should implement the `#build` method, which should use the supplied
  # Jbuilder to build the serialized representation of the record. The method is also
  # passed custom options that may be used to adapt the serialization.
  #
  #     class UserPolicy
  #       class Serializer
  #         def build json, options = {}
  #           json.id record.api_id
  #           json.name record.name
  #           json.primaryEmailMd5 Digest::MD5.hexdigest(record.primary_email.address)
  #
  #           if admin?
  #             json.primaryEmail record.primary_email.address
  #           end
  #
  #           if options[:withRoles]
  #             json.roles record.roles.collect(&:to_s)
  #           end
  #         end
  #       end
  #     end
  #
  #     user = User.find params[:id]
  #     serialization_options = { withRoles: true }
  #     json = policy_serializer(user).serialize serialization_options
  #
  # Check out `PolicyHelpers` to see what helper methods are available.
  class Serializer

    # Include helpers common to policies, policy scopes and policy serializers.
    include PolicyHelpers

    # The record to serialize.
    attr_reader :record

    # Creates a serializer instance that will serialize the specified record for the specified user.
    # The user may be a `UserContext` wrapper that will be expanded
    # (see `PolicyHelpers`).
    def initialize user, record
      @user = user
      @record = record
      expand_user_context!
    end

    # Returns the serialized representation of the record supplied at creation.
    # You may pass an options Hash to customize the serialization.
    #
    #     project = Project.find params[:id]
    #     serialization_options = {}
    #
    #     serializer = policy_serializer(project).serializer
    #     json = serializer.serialize serialization_options
    #
    # The same method can also be used to serialize associated objects. Simply pass
    # a record or Array of records as the first argument. The corresponding policies
    # and serializers will be loaded with the same current user (or current context)
    # and used to serialize the records.
    #
    #     class ProjectPolicy
    #       class Serializer
    #         def build json, options = {}
    #           json.name record.name
    #           json.organization serialize(record.organization) if options[:withOrganization]
    #         end
    #       end
    #     end
    def serialize *args
      options = args.extract_options!
      if other_record = args.shift
        if other_record.kind_of? Array
          other_record.collect do |r|
            Pundit.policy!(@user_context || @user, r).serializer.serialize options
          end
        else
          Pundit.policy!(@user_context || @user, other_record).serializer.serialize options
        end
      else
        to_builder(options).attributes!
      end
    end

    # Returns a Jbuilder that will serialize the record.
    def to_builder options = {}
      Jbuilder.new do |json|
        build json, options
      end
    end

    # Serializes the record by using the Jbuilder provided as the first argument.
    def build json, options = {}
      # To be implemented by subclasses.
    end
  end
end

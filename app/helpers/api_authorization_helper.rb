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

# Utility methods to handle authorization, available to all API classes mounted in `ProbeDock::API`.
# Also see `ApplicationPolicy` in `app/policies/application_policy.rb` to know how policies work.
module ApiAuthorizationHelper

  # Ensures that the current user is authorized to perform the specified query
  # on the specified record.
  #
  #     project = Project.find params[:id]
  #     authorize! project, :update
  #
  # The Pundit library is used to model authorizations as classes (see `app/policies`):
  # https://github.com/elabs/pundit
  #
  # The current user is automatically resolved by calling `#pundit_user`.
  # The query should be a Symbol representing an action, such as :create, :show
  # or :update (it can be a custom action). The record should be a class that has
  # a corresponding policy class (for example, the `UserPolicy` class models
  # authorization for the `User` model).
  def authorize! record, query
    query = "#{query}?" unless query.to_s.last == '?'
    Pundit.authorize pundit_user, record, query
  end

  # Returns the Pundit policy for the specified subject.
  # This methods raises an error if no corresponding policy is found.
  #
  #     project = Project.find params[:id]
  #     project_policy = policy project
  #
  # The user is automatically resolved by calling `#pundit_user` by default,
  # but it can be overriden with the second argument.
  def policy subject, user = nil
    Pundit.policy! user || pundit_user, subject
  end

  # Returns a Pundit policy scope for the specified subject.
  # This scope limits the records the user is authorized to access.
  #
  #     project_scope = policy_scope Project
  #
  # The user is automatically resolved by calling `#pundit_user`.
  def policy_scope subject
    Pundit.policy_scope! pundit_user, subject
  end

  # Returns a Pundit policy serializer that can be used to serialize the specified subject.
  #
  #     project = Project.find params[:id]
  #     serialization_options = { withOrganization: true }
  #
  #     serializer = policy_serializer project
  #     json = serializer.serialize serialization_options
  def policy_serializer subject, user = nil
    policy(subject, user).serializer
  end

  # Determines the current user for authorization with Pundit policy classes.
  #
  # This is actually a wrapper around the user model which additionally contains:
  #
  # * the current organization (if available in the context of the request);
  # * the current OTP record (if available in the context of the request);
  # * the request params.
  #
  # It is up to each API class to implement these optional contextual methods:
  #
  # * implement `#current_organization` if you want a current organization to be defined;
  # * implement `#current_otp_record` if you want a current OTP record to be defined.
  def pundit_user

    user = current_user
    org = respond_to?(:current_organization) ? current_organization : nil
    otp_record = respond_to?(:current_otp_record) ? current_otp_record : nil

    UserContext.new user, org, otp_record, params
  end
end

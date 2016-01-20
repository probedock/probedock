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

# Utilities for policy classes (policies, policy scopes and policy serializers).
module PolicyHelpers
  extend ActiveSupport::Concern

  included do
    # All policies, policy scopes and policy serializers will have these
    # attributes. See `ApiAuthorizationHelper#pundit_user` to see if and how
    # they will be available.
    attr_reader :user, :organization, :otp_record, :params
  end

  private

  # If the user supplied to a policy class is an instance of `UserContext`, its
  # contents will be unwrapped and available with the attribute readers defined above.
  def expand_user_context!
    if @user.kind_of? UserContext
      @user_context = @user
      @user = @user_context.user
      @organization = @user_context.organization
      @otp_record = @user_context.otp_record
      @params = @user_context.params
    end
  end

  # Indicates whether the current user is the application (identified by the :app Symbol).
  # Used when serializing objects in background jobs or rake tasks.
  def app?
    user == :app
  end

  # Indicates whether the current user is an administrator.
  def admin?
    role? :admin
  end

  # Indicates whether the current user is human (i.e. not a technical user).
  def human?
    user.kind_of(User) && user.try(:human?)
  end

  # Indicates whether the current user is a technical user.
  def technical?
    user.kind_of(User) && user.try(:technical?)
  end

  # Indicates whether the current user is member of the given organization
  def member_of?(organization)
    user.kind_of?(User) && organization.kind_of?(Organization) && user.try(:member_of?, organization)
  end

  # Indicates whether the given organization is public
  def public?(organization)
    organization.kind_of?(Organization) && organization.try(:public?)
  end

  # Indicates whether there is a current OTP record available.
  # Optionally, pass a class as the first argument to ensure that it is of the correct type.
  #
  #     do_something if otp_record? UserRegistration
  def otp_record? type = nil
    otp_record.present? && (type.nil? || otp_record.kind_of?(type))
  end

  # Indicates whether the current user has the specified role (or all the specified roles).
  #
  #     do_something if role? :admin
  #     break_something if role? :foo, :bar
  def role? *roles
    user.kind_of?(User) && user.has_all_roles?(*roles)
  end
end

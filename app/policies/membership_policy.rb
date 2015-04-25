# Copyright (c) 2015 42 inside
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
class MembershipPolicy < ApplicationPolicy
  def create?
    user.is?(:admin) || user.membership_in(record.organization).try(:is?, :admin)
  end

  def index?
    if organization.present?
      organization.public? || user.try(:is?, :admin) || user.try(:member_of?, organization)
    else
      user.present? || otp_record.present?
    end
  end

  def show?
    user.is?(:admin) || user.member_of?(organization)
  end

  def update?
    set_roles? || set_user? || accept?
  end

  def set_roles?
    user.is?(:admin) || user.membership_in(record.organization).try(:is?, :admin)
  end

  def set_user?
    user.is?(:admin)
  end

  def accept?
    user.emails.include?(record.organization_email) || record == otp_record
  end

  def destroy?
    user.is?(:admin) || user.membership_in(record.organization).try(:is?, :admin)
  end

  class Scope < Scope
    def resolve
      if organization.present?
        scope.where organization: organization
      elsif user.try :is?, :admin
        scope
      elsif user.present?
        scope.joins(organization_email: :user).where(user: user)
      else
        scope.none
      end
    end
  end
end

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
    user.is?(:admin) || user.member_of?(record.organization)
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
        scope.joins(organization_email: :user).where('users.id = ?', user.id)
      else
        scope.none
      end
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.organizationId record.organization.api_id
        json.organization serialize(record.organization) if options[:with_organization]
        json.roles record.roles.collect(&:to_s)
        json.createdAt record.created_at.iso8601(3)
        json.acceptedAt record.accepted_at.iso8601(3) if record.accepted_at.present?
        json.updatedAt record.updated_at.iso8601(3)

        if user.try(:is?, :admin) || user.try(:member_of?, record.organization) || otp_record
          json.organizationEmail record.organization_email.address
        end

        if record.user.present?
          json.userId record.user.api_id
          json.user serialize(record.user, link: true) if options[:with_user]
        end
      end
    end
  end
end

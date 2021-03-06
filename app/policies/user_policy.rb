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
class UserPolicy < ApplicationPolicy
  def create?
    admin? || membership_otp? || org_admin_of_technical_user?
  end

  def index?
    true
  end

  def show?
    admin? || user == record
  end

  def update?
    admin? || user == record || org_admin_of_technical_user? || (registration_otp? && !record.active)
  end

  def update_name?
    admin? || user == record || org_admin_of_technical_user?
  end

  def update_active?
    admin? || org_admin_of_technical_user? || (registration_otp? && !record.active)
  end

  def update_email?
    admin?
  end

  def update_password?
    admin? || user == record || registration_otp?
  end

  def destroy?
    admin? || org_admin_of_technical_user?
  end

  private

  def membership_otp?
    otp_record.present? && otp_record.kind_of?(Membership)
  end

  def registration_otp?
    otp_record.present? && otp_record.kind_of?(UserRegistration) && otp_record.user == record
  end

  def org_admin_of_technical_user?
    record.technical? && record.memberships.present? && user.try(:membership_in, record.memberships.first.organization).try(:admin?)
  end

  public

  class Scope < Scope
    def resolve
      scope
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.name record.name
        json.technical record.technical
        json.organizationId record.memberships.first.organization.api_id if record.technical?

        if record.human?

          # TODO: cache email MD5
          json.primaryEmailMd5 Digest::MD5.hexdigest(record.primary_email.address)

          if user == record || app? || admin? || ((user.try(:organizations) || []) & record.organizations).present?
            json.primaryEmail record.primary_email.address

            unless options[:link]
              json.emails serialize(record.emails.to_a)
            end
          end
        end

        # FIXME: only allow admin and org members to see this
        if record.technical? && options[:with_technical_membership]
          json.technicalMembership serialize(record.memberships.first, options)
        end

        if options[:with_organizations] && admin?
          json.organizations record.organizations.collect{ |org| serialize(org, options[:organization_options]) }
        end

        unless options[:link]
          json.active record.active
          json.roles record.roles.collect(&:to_s)
          json.createdAt record.created_at.iso8601(3)
        end
      end
    end
  end
end

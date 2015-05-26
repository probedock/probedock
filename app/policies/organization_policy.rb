# Copyright (c) 2015 Probe Dock
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
class OrganizationPolicy < ApplicationPolicy
  def create?
    user.is? :admin
  end

  def index?
    true
  end

  def show?
    record.public? || user.try(:is?, :admin) || user.try(:member_of?, record)
  end

  def data?
    organization.try(:public?) || user.try(:is?, :admin) || user.try(:member_of?, organization)
  end

  def update?
    user.is?(:admin) || user.membership_in(record).try(:is?, :admin)
  end

  class Scope < Scope
    def resolve
      if user.try :is?, :admin
        scope
      elsif user
        scope.joins('LEFT OUTER JOIN memberships ON organizations.id = memberships.organization_id').where('organizations.public_access = ? OR (memberships.id IS NOT NULL AND memberships.user_id = ?)', true, user.id).distinct
      else
        scope.where public_access: true
      end
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.name record.name
        json.displayName record.display_name if record.display_name.present?
        json.public record.public_access
        json.projectsCount record.projects_count
        json.membershipsCount record.memberships_count
        json.createdAt record.created_at.iso8601(3)
        json.updatedAt record.updated_at.iso8601(3)

        if options[:with_roles]
          membership = options[:current_user_memberships].find{ |m| m.organization_id == record.id }
          json.member !!membership
          json.roles membership.try(:roles) || []
        end
      end
    end
  end
end

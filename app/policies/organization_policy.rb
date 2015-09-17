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
class OrganizationPolicy < ApplicationPolicy
  def create?
    admin?
  end

  def index?
    true
  end

  def show?
    record.public? || admin? || user.try(:member_of?, record)
  end

  def data?
    organization.try(:public?) || admin? || user.try(:member_of?, organization)
  end

  def update?
    admin? || user.membership_in(record).try(:is?, :admin)
  end

  class Scope < Scope
    def resolve
      # Everyone can index and show any organization, but only
      # the name will be serialized for anonymous users and non-members.
      scope
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.name record.name
        json.public record.public_access

        if record.public? || app? || admin? || user.try(:member_of?, record)
          json.displayName record.display_name if record.display_name.present?
          json.projectsCount record.projects_count
          json.membershipsCount record.memberships_count
          json.createdAt record.created_at.iso8601(3)
          json.updatedAt record.updated_at.iso8601(3)

          if options[:with_roles]
            membership = options[:current_user_memberships].find{ |m| m.organization_id == record.id }
            json.member !!membership
            json.roles membership.try(:roles) || []
          end

          if options[:with_memberships]
            json.memberships record.memberships.collect{ |m| serialize m, options[:membership_options] }
          end

          if options[:with_projects]
            json.projects record.projects.collect{ |p| serialize p, options[:project_options] }
          end
        end
      end
    end
  end
end

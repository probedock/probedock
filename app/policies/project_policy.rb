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
class ProjectPolicy < ApplicationPolicy
  def create?
    admin? || user.membership_in(record.organization).try(:is?, :admin)
  end

  def index?
    admin? || public?(organization) || member_of?(organization)
  end

  def show?
    admin? || public?(organization) || member_of?(organization)
  end

  def update?
    user.is?(:admin) || user.membership_in(record.organization).try(:is?, :admin)
  end

  def publish?
    user.member_of? record.organization
  end

  class Scope < Scope
    def resolve
      if user.try :is?, :admin
        scope
      else
        scope.where organization: organization
      end
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.name record.name
        json.displayName record.display_name if record.display_name.present?
        json.organizationId record.organization.api_id
        json.repoUrl record.repo_url if record.repo_url.present?
        json.lastReportId record.last_report.api_id if record.last_report.present?

        unless options[:link]
          json.description record.description if record.description.present?
          json.testsCount record.tests_count
          json.createdAt record.created_at.iso8601(3)
          json.updatedAt record.updated_at.iso8601(3)
        end
      end
    end
  end
end

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
class ProjectTestPolicy < ApplicationPolicy
  def show?
    user.try(:is?, :admin) || record.project.organization.try(:public?) || user.try('member_of?', record.project.try(:organization))
  end

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
        json.category record.description.category.name
        json.key record.key.key if record.key.present?
        json.resultsCount record.results_count
        json.firstRunAt record.first_run_at.iso8601(3)
        json.lastRunAt record.description.last_run_at.iso8601(3)
        json.projectVersion record.description.project_version.name
        json.passing record.description.passing
        json.active record.description.active
        json.tags record.description.tags.collect{ |t| t.name }
        json.tickets record.description.tickets.collect{ |t| t.name }
        json.project serialize(record.project) if options[:with_project]
      end
    end
  end
end

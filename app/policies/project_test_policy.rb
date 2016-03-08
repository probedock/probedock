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
    admin? || public?(record.project.organization) || member_of?(record.project.organization)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  class Serializer < Serializer
    include ScmHelper

    def to_builder options = {}
      last_result = record.description.last_result
      payload = options[:payloads].find{ |p| p.id == last_result.test_payload_id } if options[:payloads]
      source_url = build_source_url(last_result, record.project, payload)

      Jbuilder.new do |json|
        json.id record.api_id
        json.name record.name
        json.category record.description.category.name if record.description.category
        json.key record.key.key if record.key.present?
        json.resultsCount record.results_count
        json.firstRunAt record.first_run_at.iso8601(3)
        json.lastRunAt record.description.last_run_at.iso8601(3)
        json.projectVersion record.description.project_version.name
        json.passing record.description.passing
        json.active record.description.active
        json.tags record.description.tags.collect(&:name)
        json.tickets record.description.tickets.collect(&:name)
        json.contributions serialize(record.description.contributions.to_a) if options[:with_contributions]
        json.project serialize(record.project) if options[:with_project]
        json.sourceUrl source_url if source_url
        if options[:with_scm]
          json.scm build_scm_data(payload)
        end
      end
    end
  end
end

# Copyright (c) 2016 ProbeDock
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
class OrganizationTableInfoPolicy < ApplicationPolicy
  def show?
    admin? || org_admin?(organization)
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.organizations record.organizations_counts do |organization_counts|
          json.id organization_counts[:id]
          json.name organization_counts[:name]
          json.displayName organization_counts[:display_name] unless organization_counts[:display_name].nil?
          json.payloadsCount organization_counts[:test_payloads_count]
          json.projectsCount organization_counts[:projects_count]
          json.testsCount organization_counts[:project_tests_count]
          json.resultsCount organization_counts[:test_results_count]
          json.resultsTrend organization_counts[:results_trend]
        end
        json.payloadsCount record.total_counts[:test_payloads_count]
        json.projectsCount record.total_counts[:projects_count]
        json.testsCount record.total_counts[:project_tests_count]
        json.resultsCount record.total_counts[:test_results_count]
      end
    end
  end
end

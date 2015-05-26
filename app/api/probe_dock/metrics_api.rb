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
module ProbeDock
  class MetricsApi < Grape::API
    namespace :metrics do
      before do
        authenticate
      end

      helpers do
        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      get :'new-tests' do
        authorize! :organization, :data

        rel = ProjectTest.joins(:project).where(projects: { organization_id: current_organization.id }).select("count(project_tests.id) as project_tests_count, date_trunc('day', project_tests.first_run_at) as project_tests_day")
        rel = rel.where 'project_tests.first_run_at >= ?', 30.days.ago
        rel = rel.group('project_tests_day').order('project_tests_day').limit(7)

        rel.to_a.collect do |data|
          {
            date: data.project_tests_day.strftime('%Y-%m-%d'),
            testsCount: data.project_tests_count
          }
        end
      end
    end
  end
end

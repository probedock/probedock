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
module ProbeDock
  class MetricsApi < Grape::API
    namespace :metrics do
      before do
        authenticate
      end

      helpers do
        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.active.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.active.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      get :newTests do
        authorize! :organization, :data

        start_date = 29.days.ago.beginning_of_day

        rel = ProjectTest.joins(:project).where('projects.organization_id = ?', current_organization.id).select("count(project_tests.id) as project_tests_count, date_trunc('day', project_tests.first_run_at) as project_tests_day")
        rel = rel.where 'project_tests.first_run_at >= ?', start_date

        if params[:projectIds].present? && params[:projectIds].kind_of?(Array)
          rel = rel.where 'projects.api_id IN (?)', params[:projectIds].collect(&:to_s)
        end

        if params[:userIds].present? && params[:userIds].kind_of?(Array)

          users = User.where('api_id IN (?)', params[:userIds].collect(&:to_s)).to_a
          rel = rel.joins 'LEFT OUTER JOIN test_keys ON project_tests.key_id = test_keys.id'

          user_ids = users.collect &:id
          rel = rel.where '(test_keys.user_id IS NOT NULL AND test_keys.user_id IN (?)) OR (test_keys.user_id IS NULL AND project_tests.first_runner_id IN (?))', user_ids, user_ids
        end

        rel = rel.group('project_tests_day').order('project_tests_day DESC')

        counts = rel.to_a.inject({}){ |memo,data| memo[data.project_tests_day.strftime('%Y-%m-%d')] = data.project_tests_count; memo }

        result = []
        current_date = start_date

        30.times do |i|
          date = current_date.strftime('%Y-%m-%d')
          result << { date: date, testsCount: counts.fetch(date, 0) }
          current_date += 1.day
        end

        result
      end

      get :team do
        authorize! :organization, :data

        project = nil
        project = Project.where(organization_id: current_organization.id, api_id: params[:projectId]).first! if params[:projectId]

        category_rel = if project
          Category.joins(test_descriptions: [ :contributors, :project_version ]).where 'project_versions.project_id = ?', project.id
        else
          Category.joins(test_descriptions: :contributors)
        end

        with_user = true_flag? :withUser

        user_joins = { test_contributors: { test_description: { test: :project } } }
        user_select_clause = 'users.*, count(distinct project_tests.id) AS tests_count'
        user_order = 'tests_count DESC, users.name ASC'

        user_conditions = [ 'projects.organization_id = ?' ]
        user_values = [ current_organization.id ]

        if project
          user_conditions << 'projects.id = ?'
          user_values << project.id
        end

        user_where_clause = user_values.unshift user_conditions.join(' AND ')

        User.select(user_select_clause).joins(user_joins).where(user_where_clause).group('users.id').order(user_order).to_a.collect do |user|

          contributor = {
            userId: user.api_id,
            testsCount: user.tests_count,
            categories: category_rel.where('test_contributors.user_id = ?', user.id).distinct.pluck(:name)
          }

          contributor[:user] = policy_serializer(user).serialize if with_user

          contributor
        end
      end
    end
  end
end

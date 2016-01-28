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
    DEFAULT_NB_DAYS_FOR_REPORTS = 30
    MAX_NB_DAYS_FOR_REPORTS = 120

    DEFAULT_NB_DAYS_FOR_NEW_TESTS = 30
    MAX_NB_DAYS_FOR_NEW_TESTS = 120

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
          elsif params[:projectId].present?
            Organization.active.joins(:projects).where('projects.api_id = ?', params[:projectId].to_s).first!
          elsif params[:projectVersionId].present?
            Organization.active.joins(projects: [:versions]).where('project_versions.api_id = ?', params[:projectVersionId]).first!
          end
        end
      end

      get :newTestsByDay do
        authorize! :organization, :data

        nb_days = params[:nbDays].to_i
        nb_days = MAX_NB_DAYS_FOR_NEW_TESTS if nb_days > MAX_NB_DAYS_FOR_NEW_TESTS
        nb_days = DEFAULT_NB_DAYS_FOR_NEW_TESTS if nb_days <= 0
        nb_days

        start_date = (nb_days - 1).days.ago.beginning_of_day

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

        nb_days.times do |i|
          date = current_date.strftime('%Y-%m-%d')
          result << { date: date, testsCount: counts.fetch(date, 0) }
          current_date += 1.day
        end

        result
      end

      get :reportsByDay do
        authorize! :organization, :data

        nb_days = params[:nbDays].to_i
        nb_days = MAX_NB_DAYS_FOR_REPORTS if nb_days > MAX_NB_DAYS_FOR_REPORTS
        nb_days = DEFAULT_NB_DAYS_FOR_REPORTS if nb_days <= 0
        nb_days

        start_date = (nb_days - 1).days.ago.beginning_of_day

        rel = TestReport.where('test_reports.organization_id = ?', current_organization.id).select("count(distinct test_reports.id) as runs_count, date_trunc('day', test_reports.ended_at) as runs_day")
        rel = rel.where 'test_reports.ended_at >= ?', start_date

        # Set filters by
        filter_by_projects = params[:projectIds].present? && params[:projectIds].kind_of?(Array)
        filter_by_users = params[:userIds].present? && params[:userIds].kind_of?(Array)

        # Prepare additional join for test_payloads
        payload_joins = []
        payload_joins << { project_version: :project } if filter_by_projects
        payload_joins << :runner if filter_by_users

        rel = rel.joins(test_payloads: payload_joins) unless payload_joins.empty?

        # Apply filters
        rel = rel.where 'projects.api_id IN (?)', params[:projectIds].collect(&:to_s) if filter_by_projects
        rel = rel.where 'users.api_id IN (?)', params[:userIds].collect(&:to_s) if filter_by_users

        rel = rel.group('runs_day').order('runs_day DESC')

        counts = rel.to_a.inject({}){ |memo,data| memo[data.runs_day.strftime('%Y-%m-%d')] = data.runs_count; memo }

        result = []
        current_date = start_date

        nb_days.times do |i|
          date = current_date.strftime('%Y-%m-%d')
          result << { date: date, runsCount: counts.fetch(date, 0) }
          current_date += 1.day
        end

        result
      end

      get :projectHealth do
        authorize! :organization, :data


        # Retrieve the data from the specified version otherwise take the most recent project version to retrieve the data
        if params[:projectVersionId].present?
          project_version = ProjectVersion.where('api_id = ?', params[:projectVersionId]).first
        else
          project_version = ProjectVersion.joins(:project).where('projects.api_id = ?', params[:projectId]).order('created_at DESC').first
        end

        tests_counts = TestDescription.joins(:project_version).where('project_versions.id = ?', project_version.id)

        # In this statement, we use nullif which return null if left value is equal to right value. Therefore, we want to
        # count the opposite of this results as COUNT will not take into account null values. Ex: all passing tests have
        # value set to true and then we want to remove the failing ones. Then, we want nullif to return null when passing
        # is false.
        tests_counts = tests_counts.select(
          # Count the number of passed tests even if they are inactive
          'count(nullif(passing, false)) as passed_tests_count, ' +

          # Count the number of inactive tests
          'count(nullif(active, true)) as inactive_tests_count, ' +

          # Count the number of inactive passing tests
          'count(nullif(passing and not active, false)) as inactive_passed_tests_count, ' +

          # Count the number of used tests meaning the tests where results have been received for the project version
          'count(*) as run_tests_count'
        ).take

        # Count the number of tests for the specific versions
        project_tests_rel = ProjectTest.joins(:project).where('projects.id = ?', project_version.project.id)

        {
          testsCount: project_tests_rel.count,
          passedTestsCount: tests_counts.passed_tests_count,
          inactiveTestsCount: tests_counts.inactive_tests_count,
          inactivePassedTestsCount: tests_counts.inactive_passed_tests_count,
          runTestsCount: tests_counts.run_tests_count,
          projectVersion: serialize(project_version)
        }
      end

      # GET /api/metrics/contributions?organizationId&projectId&withUser
      #
      # Returns the list of contributions for an organization or project.
      # Ordered by descending number of tests and ascending user name.
      #
      #     [
      #       {
      #         "userId": "abcde",
      #         "testsCount": 123,
      #         "categories": [ "JUnit", "Karma" ]
      #       },
      #       {
      #         "userId": "bcdef",
      #         "testsCount": 45,
      #         "categories": [ "JUnit", "Karma" ]
      #       }
      #     ]
      get :contributions do
        authorize! :organization, :data

        # load optional project filter
        project = nil
        project = Project.where(organization_id: current_organization.id, api_id: params[:projectId]).first! if params[:projectId]

        # query all categories linked to the organization, and all contributions that have been made for those categories
        category_joins = { test_descriptions: [ :contributions, { test: :project } ] }
        category_select = 'categories.*, array_agg(distinct test_contributions.user_id) AS contributor_ids'
        category_where = [ 'projects.organization_id = ?', current_organization.id ]

        # if a project ID is given, limit the query to the project in question
        if project
          category_joins[:test_descriptions][1] = :test # no need to join with the projects table any more
          category_where = [ 'project_tests.project_id = ?', project.id ]
        end

        # load the categories
        categories_with_contributors = Category.select(category_select).joins(category_joins).where(*category_where).group('categories.id').to_a

        # query all users that have contributed within the organization, and the number of tests they have written
        user_joins = { test_contributions: { test_description: { test: :project } } }
        user_select = 'users.*, count(distinct project_tests.id) AS tests_count'
        user_order = 'tests_count DESC, users.name ASC'

        user_conditions = [ 'projects.organization_id = ?' ]
        user_values = [ current_organization.id ]

        # if a project ID is given, limit the query to the project in question
        if project
          user_conditions << 'projects.id = ?'
          user_values << project.id
        end

        user_where = user_values.unshift user_conditions.join(' AND ')

        # load the users
        contributors = User.select(user_select).joins(user_joins).where(user_where).group('users.id').order(user_order).to_a

        # send the response
        with_user = true_flag? :withUser

        contributors.collect do |user|

          contribution = {
            userId: user.api_id,
            testsCount: user.tests_count,
            categories: categories_with_contributors.select{ |cat| cat.contributor_ids.include? user.id }.collect(&:name).sort
          }

          contribution[:user] = policy_serializer(user).serialize if with_user

          contribution
        end
      end
    end
  end
end

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

    DEFAULT_NB_WEEKS_FOR_TESTS = 10
    MAX_NB_WEEKS_FOR_TESTS = 52

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

        # Returns the specified relation filtered to match only the projects specified in the :projectIds query parameter.
        # The original relation is not modified.
        #
        # This method requires that the :projects table be available in the relation.
        def apply_projects_filter(rel)
          if array_param?(:projectIds)
            rel = rel.where('projects.api_id IN (?)', params[:projectIds].collect(&:to_s))
          end

          rel
        end

        # Returns the specified relation filtered to match only the tests authored by the users specified in the :userIds query parameter.
        # A test is defined to have been authored by a user if that user owns the corresponding test key, or if he was the first to run the test.
        # The original relation is not modified.
        #
        # This method requires that the :project_tests table be available in the relation.
        def apply_users_filter(rel)
          if array_param?(:userIds)
            users = User.select(:id).where('api_id IN (?)', params[:userIds].collect(&:to_s)).to_a

            rel = rel.joins('LEFT OUTER JOIN test_keys ON project_tests.key_id = test_keys.id')

            user_ids = users.collect(&:id)
            rel = rel.where('(test_keys.user_id IS NOT NULL AND test_keys.user_id IN (?)) OR (test_keys.user_id IS NULL AND project_tests.first_runner_id IN (?))', user_ids, user_ids)
          end

          rel
        end

        # Returns the specified relation filtered through both `apply_projects_filter` and `apply_users_filter`.
        # The original relation is not modified.
        def apply_projects_and_users_filters(rel)
          rel = apply_projects_filter(rel)
          rel = apply_users_filter(rel)
          rel
        end

        # Returns the number of tests by interval since the specified date.
        #
        # See the following PostgreSQL documentation for the available intervals:
        # http://www.postgresql.org/docs/9.4/static/functions-datetime.html#FUNCTIONS-DATETIME-TRUNC
        def count_new_tests_by_interval(start_date, interval)

          # Select the number of tests grouped by date, truncated to the specified interval (e.g. day, week)
          rel = ProjectTest
            .select("count(project_tests.id) as project_tests_count, date_trunc('#{interval}', project_tests.first_run_at) as project_tests_by_interval")
            .group('project_tests_by_interval')

          # Filter to match only the current organization
          rel = rel.joins(:project).where('projects.organization_id = ?', current_organization.id)

          # Filter to match only the tests created since the specified start date
          rel = rel.where('project_tests.first_run_at >= ?', start_date)

          # Filter by projects and users
          rel = apply_projects_and_users_filters(rel)

          # Order by descending date
          rel = rel.order('project_tests_by_interval DESC')

          rel.to_a.inject({}) do |memo,data|
            memo[data.project_tests_by_interval.strftime('%Y-%m-%d')] = data.project_tests_count
            memo
          end
        end

        # Returns the current project version corresponding to query parameters:
        #
        # * If the :projectVersionId query parameter is given, the corresponding project version is returned.
        # * If the :projectId query parameter is given, the last created version for that project is returned (or nil if there is none).
        # * Otherwise, nil is returned.
        def current_project_version
          if params[:projectVersionId].present?
            ProjectVersion.where('api_id = ?', params[:projectVersionId]).first!
          elsif params[:projectId]
            ProjectVersion.joins(:project).where('projects.api_id = ?', params[:projectId]).order('created_at DESC').first
          else
            nil
          end
        end
      end

      get :newTestsByDay do
        authorize!(:organization, :data)

        nb_days = params[:nbDays].to_i
        nb_days = MAX_NB_DAYS_FOR_NEW_TESTS if nb_days > MAX_NB_DAYS_FOR_NEW_TESTS
        nb_days = DEFAULT_NB_DAYS_FOR_NEW_TESTS if nb_days <= 0
        nb_days

        start_date = (nb_days - 1).days.ago.beginning_of_day

        result = []
        current_date = start_date

        tests_counts = count_new_tests_by_interval(start_date, :day)

        nb_days.times do |i|
         date = current_date.strftime('%Y-%m-%d')
         result << { date: date, testsCount: tests_counts.fetch(date, 0) }
         current_date += 1.day
        end

        result
      end

      get :reportsByDay do
        authorize!(:organization, :data)

        nb_days = params[:nbDays].to_i
        nb_days = MAX_NB_DAYS_FOR_REPORTS if nb_days > MAX_NB_DAYS_FOR_REPORTS
        nb_days = DEFAULT_NB_DAYS_FOR_REPORTS if nb_days <= 0
        nb_days

        start_date = (nb_days - 1).days.ago.beginning_of_day

        # Select the number of test reports grouped by day
        rel = TestReport
          .select("count(distinct test_reports.id) as runs_count, date_trunc('day', test_reports.ended_at) as runs_day")
          .group('runs_day')

        # Filter to match only the current organization
        rel = rel.where('test_reports.organization_id = ?', current_organization.id)

        # Filter to match only the test reports received since the specified start date
        rel = rel.where('test_reports.ended_at >= ?', start_date)

        # Check which filters will be applied
        filter_by_projects = array_param? :projectIds
        filter_by_users = array_param? :userIds

        # Prepare test payload joins, depending on which filters are present
        payload_joins = []
        payload_joins << { project_version: :project } if filter_by_projects
        payload_joins << :runner if filter_by_users

        # Apply test payload joins
        rel = rel.joins(test_payloads: payload_joins) unless payload_joins.empty?

        # Filter by projects and users
        rel = rel.where('projects.api_id IN (?)', params[:projectIds].collect(&:to_s)) if filter_by_projects
        rel = rel.where('users.api_id IN (?)', params[:userIds].collect(&:to_s)) if filter_by_users

        # Order by descending date
        rel = rel.order('runs_day DESC')

        counts = rel.to_a.inject({}) do |memo,data|
          memo[data.runs_day.strftime('%Y-%m-%d')] = data.runs_count
          memo
        end

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
        authorize!(:organization, :data)

        project_version = current_project_version

        if project_version.blank?
          return {
            testsCount: 0,
            passedTestsCount: 0,
            inactiveTestsCount: 0,
            inactivePassedTestsCount: 0,
            runTestsCount: 0
          }
        end

        tests_counts = TestDescription.joins(:project_version).where('project_versions.id = ?', project_version.id)

        # In this query, we use nullif which return null if left value is equal to right value. Therefore, we want to
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

      get :testsByWeek do
        authorize! :organization, :data

        nb_weeks = params[:nbWeeks].to_i
        nb_weeks = MAX_NB_WEEKS_FOR_TESTS if nb_weeks > MAX_NB_WEEKS_FOR_TESTS
        nb_weeks = DEFAULT_NB_WEEKS_FOR_TESTS if nb_weeks <= 0
        nb_weeks

        start_date = (nb_weeks - 1).weeks.ago.beginning_of_week

        # Count the total number of tests
        rel = ProjectTest.select('count(project_tests.id) as total_tests_count')
        # Filter to match only the current organization.
        rel = rel.joins(:project).where('projects.organization_id = ?', current_organization.id)
        # Filter to match only the tests created before the specified start date
        rel = rel.where('project_tests.first_run_at < ?', start_date)
        # Filter by projects and users
        rel = apply_projects_and_users_filters rel
        # Retrieve the count
        total_tests_count = rel.take.total_tests_count

        result = []
        current_date = start_date

        tests_count = count_new_tests_by_interval(start_date, :week)

        nb_weeks.times do |i|
          date = current_date.strftime('%Y-%m-%d')
          total_tests_count = total_tests_count + tests_count.fetch(date, 0)
          result << { date: date, testsCount: total_tests_count }
          current_date += 1.week
        end

        result
      end

      get :testsByCategories do
        authorize!(:organization, :data)

        # Check which filters will be applied
        filter_by_projects = array_param?(:projectIds)
        filter_by_users = array_param?(:userIds)

        # Try to retrieve the project version
        project_version = current_project_version

        project_versions = if project_version
          [ project_version.id ]
        else
          # Retrieve the latest version by project
          rel = ProjectVersion
            .joins(:project)
            .select('distinct on (projects.name) project_versions.id')
            .order('projects.name, project_versions.created_at DESC')

          rel = if filter_by_projects
            # Filter by projects if specified
            apply_projects_filter(rel)
          else
            # Otherwise, filter to match only the current organization
            rel.where('projects.organization_id = ?', @current_organization.id)
          end

          rel.collect(&:id)
        end

        # Prepare additional join for categories_counts
        categories_counts_joins = [ 'LEFT OUTER JOIN categories ON test_descriptions.category_id = categories.id', :project_version ]
        categories_counts_joins << { test: :first_runner } if filter_by_users

        # Retrieve the number of tests by category
        categories_counts_rel = TestDescription
          .select('categories.name, count(test_descriptions.*) as categories_tests_count')
          .group('test_descriptions.category_id, categories.name')

        # Filter to match only the selected project versions
        categories_counts_rel = categories_counts_rel.joins(categories_counts_joins).where('project_versions.id IN (?)', project_versions)

        # Filter by users if specified
        categories_counts_rel = apply_users_filter(categories_counts_rel)

        # Order by ascending category name (the null category will be at the end, if any)
        categories_counts_rel = categories_counts_rel.order('categories.name ASC')

        # Perform the query and retrieve the counts
        categories_counts = categories_counts_rel.to_a

        # Extract the number of tests without a category (last in the array, if present)
        # and remove it from the original array
        no_category_tests_count = 0
        if categories_counts.present? && categories_counts.last.name.nil?
          no_category_tests_count = categories_counts.last.categories_tests_count
          categories_counts.slice!(-1)
        end

        {
          noCategoryTestsCount: no_category_tests_count,
          categories: categories_counts.collect do |category_metric|
            {
              name: category_metric.name,
              testsCount: category_metric.categories_tests_count
            }
          end
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
        authorize!(:organization, :data)

        # Load the optional project filter
        project = nil
        project = Project.where(organization_id: current_organization.id, api_id: params[:projectId]).first! if params[:projectId]

        # Select test contributors by category
        category_rel = Category
          .select('categories.*, array_agg(distinct test_contributions.user_id) AS contributor_ids')
          .group('categories.id')

        category_joins = { test_descriptions: [ :contributions, { test: :project } ] }
        category_where = [ 'projects.organization_id = ?', current_organization.id ]

        # If a project ID is given, limit the query to the project in question
        if project
          # No need to join with the :projects table any more
          # (replace `{ test: :project }` by `:test` in `category_joins`)
          category_joins[:test_descriptions][1] = :test
          category_where = [ 'project_tests.project_id = ?', project.id ]
        end

        # Load the categories
        categories_with_contributors = category_rel.joins(category_joins).where(*category_where).to_a

        # Query all users that have contributed within the organization, and the number of tests they have written
        user_rel = User
          .select('users.*, count(distinct project_tests.id) AS tests_count')
          .group('users.id')

        # Order by descending number of tests, then by user name
        user_rel = user_rel.order('tests_count DESC, users.name ASC')

        user_joins = { test_contributions: { test_description: { test: :project } } }
        user_conditions = [ 'projects.organization_id = ?' ]
        user_values = [ current_organization.id ]

        # Filter by project if specified
        if project
          user_conditions << 'projects.id = ?'
          user_values << project.id
        end

        user_where = user_values.unshift(user_conditions.join(' AND '))

        # Load the users
        contributors = user_rel.joins(user_joins).where(user_where).to_a

        with_user = true_flag?(:withUser)

        contributors.collect do |user|

          contribution = {
            userId: user.api_id,
            testsCount: user.tests_count,
            categories: categories_with_contributors.select { |cat| cat.contributor_ids.include?(user.id) }.collect(&:name).sort
          }

          contribution[:user] = policy_serializer(user).serialize if with_user

          contribution
        end
      end

      get :versionsWithNoResult do
        authorize!(:organization, :data)

        project_versions_rel = policy_scope(ProjectVersion).order('project_versions.created_at DESC')
        project_versions_rel = project_versions_rel.joins(project: [:tests, :organization])
          .where('organizations.api_id = ?', current_organization.api_id)
          .where('project_tests.api_id = ?', params[:testId].to_s)
          .where('not exists(select id from test_results where test_results.project_version_id = project_versions.id and test_results.test_id = project_tests.id)')
          .where('project_versions.created_at > project_tests.first_run_at')

        serialize load_resources(project_versions_rel)
      end

    end
  end
end

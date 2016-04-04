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
  class ReportsApi < Grape::API

    namespace :reports do
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
          end
        end

        def with_serialization_includes rel
          rel = rel.includes :organization
          rel = rel.includes :projects if true_flag? :withProjects
          rel = rel.includes :project_versions if true_flag? :withProjectVersions
          rel = rel.includes :runners if true_flag? :withRunners
          rel
        end

        def serialization_options reports
          @serialization_options ||= {
            with_organization: true_flag?(:withOrganization),
            with_projects: true_flag?(:withProjects),
            with_project_versions: true_flag?(:withProjectVersions),
            with_runners: true_flag?(:withRunners),
            with_categories: true_flag?(:withCategories),
            with_tags: true_flag?(:withTags),
            with_tickets: true_flag?(:withTickets),
            with_project_counts_for: params[:withProjectCountsFor].try(:to_s)
          }
        end
      end

      get do
        authorize! TestReport, :index

        test_report_rel = policy_scope(TestReport).order('test_reports.created_at DESC')

        test_report_rel = paginated(test_report_rel) do |paginated_rel|
          group = false

          if params[:uid]
            paginated_rel = paginated_rel.where(uid: params[:uid].to_s)
          end

          if params[:payloadId]
            paginated_rel = paginated_rel.joins(:test_payloads).where('test_payloads.api_id = ?', params[:payloadId].to_s)
          end

          if params[:after]
            ref = TestReport.select('id, created_at').where(api_id: params[:after].to_s).first!
            paginated_rel = paginated_rel.where('test_reports.created_at > ?', ref.created_at)
          end

          report_joins = []
          report_joins << :runners if array_param?(:runnerIds) || params[:technical]
          report_joins << :projects if array_param?(:projectIds) || params[:projectId].present?

          if array_param?(:projectVersionIds) || array_param?(:projectVersionNames) || array_param?(:categoryNames) || array_param?(:status) || array_param?(:kind)
            payload_joins = []
            payload_joins << :project_version if array_param?(:projectVersionIds) || array_param?(:projectVersionNames)
            payload_joins << :categories if array_param?(:categoryNames)

            if payload_joins.empty?
              report_joins << :test_payloads
            else
              report_joins << { test_payloads: payload_joins }
            end
          end

          paginated_rel = paginated_rel.joins(report_joins)

          if array_param?(:runnerIds)
            paginated_rel = paginated_rel.where('users.api_id in (?)', params[:runnerIds].collect(&:to_s).to_a)
          end

          if params[:technical].present?
            paginated_rel = paginated_rel.where('users.technical = ?', true_flag?(:technical))
          end

          if params[:projectId].present?
            paginated_rel = paginated_rel.where('projects.api_id = ?', params[:projectId].to_s)
          end

          if array_param?(:projectIds)
            paginated_rel = paginated_rel.where('projects.api_id in (?)', params[:projectIds].collect(&:to_s).to_a)
          end

          if array_param?(:projectVersionIds)
            paginated_rel = paginated_rel.where('project_versions.api_id in (?)', params[:projectVersionIds].collect(&:to_s).to_a)
          end

          if array_param?(:projectVersionNames)
            paginated_rel = paginated_rel.where('project_versions.name in (?)', params[:projectVersionNames].collect(&:to_s).to_a)
          end

          if array_param?(:categoryNames)
            paginated_rel = paginated_rel.where('categories.name in (?)', params[:categoryNames].collect(&:to_s).to_a)
            group = true
          end

          if array_param?(:status) || array_param?(:kind)
            where_clauses = []

            if array_param?(:status)
              where_clauses << 'test_payloads.passed_results_count > 0' if params[:status].include?('passed')
              where_clauses << 'test_payloads.results_count - test_payloads.passed_results_count - test_payloads.inactive_results_count > 0' if params[:status].include?('failed')
              where_clauses << 'test_payloads.inactive_results_count > 0' if params[:status].include?('inactive')
            end

            if array_param?(:kind)
              where_clauses << 'test_payloads.tests_count - test_payloads.new_tests_count > 0' if params[:kind].include?('existing')
              where_clauses << 'test_payloads.new_tests_count > 0' if params[:kind].include?('new')
            end

            complete_clause = ''
            where_clauses.each_with_index do |clause, idx|
              complete_clause += clause
              if idx < where_clauses.size - 1
                complete_clause += ' OR '
              end
            end

            paginated_rel = paginated_rel.where(complete_clause)
          end

          @pagination_filtered_count = paginated_rel.count('distinct test_reports.id')

          paginated_rel = paginated_rel.group('test_reports.id') if group

          paginated_rel
        end

        serialize load_resources(test_report_rel)
      end

      namespace '/:id' do

        helpers do
          def record
            @record ||= TestReport.where(api_id: params[:id].to_s).first!
          end

          def report_health_template
            @report_health_template ||= Slim::Template.new(Rails.root.join('app', 'views', 'reports', 'health.html.slim').to_s)
          end

          def with_serialization_includes rel
            rel
          end
        end

        get do
          authorize! record, :show
          serialize record, detailed: true
        end

        get :health do
          authorize! record, :show

          categories = Category.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('categories.name').pluck('distinct categories.name')
          tags = Tag.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tags.name').pluck('distinct tags.name')
          tickets = Ticket.joins(test_results: { test_payload: :test_reports }).where(test_reports: { id: record.id }).order('tickets.name').pluck('distinct tickets.name')
          helper = ReportsHelper::Template.new categories, tags, tickets

          html = ''

          offset = 0
          limit = 100

          begin
            current_results = record.results.order('name, id').offset(offset).limit(limit).includes(:key, :category, :tags, :tickets).to_a
            html << report_health_template.render(OpenStruct.new(results: current_results, helper: helper))
            offset += limit
          end while current_results.present?

          {
            html: html
          }
        end
      end
    end
  end
end

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
          end
        end

        def with_serialization_includes rel
          rel = rel.includes :projects if true_flag? :withProjects
          rel = rel.includes :project_versions if true_flag? :withProjectVersions
          rel = rel.includes :runners if true_flag? :withRunners
          rel
        end

        def serialization_options reports
          @serialization_options ||= {
            with_projects: true_flag?(:withProjects),
            with_project_versions: true_flag?(:withProjectVersions),
            with_runners: true_flag?(:withRunners)
          }
        end
      end

      get do
        authorize! TestReport, :index

        rel = policy_scope(TestReport).order 'created_at DESC'

        rel = paginated rel do |rel|

          if params[:after]
            ref = TestReport.select('id, created_at').where(api_id: params[:after].to_s).first!
            rel = rel.where 'created_at > ?', ref.created_at
          end

          rel
        end

        serialize load_resources(rel)
      end

      namespace '/:id' do

        helpers do
          def record
            @record ||= TestReport.where(api_id: params[:id].to_s).first!
          end

          def report_health_template
            @report_health_template ||= Slim::Template.new(Rails.root.join('app', 'views', 'reports', 'health.html.slim').to_s)
          end
        end

        get do
          authorize! record, :show
          serialize record, detailed: true
        end

        get :health do
          authorize! record, :show

          html = ''

          offset = 0
          limit = 100

          begin
            current_results = record.results.order('name, id').offset(offset).limit(limit).includes(test: :key).to_a
            html << report_health_template.render(OpenStruct.new(results: current_results))
            offset += limit
          end while current_results.present?

          {
            html: html
          }
        end

        get :results do
          authorize! record, :show

          rel = record.results.order('active desc, passed, name, id').includes(:key, :category, :tags, :tickets, :runner, { project_version: :project })
          rel = paginated rel

          serialize load_resources(rel)
        end
      end
    end
  end
end

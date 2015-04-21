# Copyright (c) 2015 42 inside
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
  class ReportsApi < Grape::API

    namespace :reports do
      before do
        authenticate
      end

      helpers do
        def current_organization
          if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      get do
        authorize! TestReport, :index
        rel = policy_scope(TestReport).order 'created_at DESC'

        rel = paginated rel do |rel|
          if params[:after]
            ref = TestReport.select('id, created_at').where(api_id: params[:after].to_s).first!
            rel.where 'created_at > ?', ref.created_at
          else
            rel
          end
        end

        rel.to_a.collect{ |r| r.to_builder.attributes! }
      end

      namespace '/:id' do

        helpers do
          def current_report
            @current_report ||= TestReport.where(api_id: params[:id].to_s).first!
          end

          def report_health_template
            @report_health_template ||= Slim::Template.new(Rails.root.join('app', 'views', 'reports', 'health.html.slim').to_s)
          end
        end

        get do
          report = current_report
          authorize! report, :show
          report.to_builder(detailed: true).attributes!
        end

        get :health do
          report = current_report
          authorize! report, :show

          html = ''

          offset = 0
          limit = 100

          begin
            current_results = report.results.order('name, id').offset(offset).limit(limit).to_a
            html << report_health_template.render(OpenStruct.new(results: current_results))
            offset += limit
          end while current_results.present?

          {
            html: html
          }
        end

        get :results do
          report = current_report
          authorize! report, :show

          results = report.results
          total = results.count

          limit = params[:pageSize].to_i
          limit = 100 if limit <= 0 || limit > 100

          page = params[:page].to_i
          page = 1 if page < 1
          offset = (page - 1) * limit

          header 'X-Pagination', "page=#{page} pageSize=#{limit} total=#{total}"
          results.order('active desc, passed, name, id').offset(offset).limit(limit).to_a.collect{ |r| r.to_builder.attributes! }
        end
      end
    end
  end
end

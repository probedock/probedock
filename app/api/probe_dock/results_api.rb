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
  class ResultsApi < Grape::API
    namespace :results do
      before do
        authenticate
      end

      helpers do
        def current_organization
          @current_organization ||= if params[:reportId].present?
            Organization.active.joins(:reports).where('test_reports.api_id = ?', params[:reportId]).first!
          elsif params[:projectId].present?
            Organization.active.joins(:projects).where('projects.api_id = ?', params[:projectId]).first!
          elsif params[:projectVersionId].present?
            Organization.active.joins(projects: :versions).where('project_versions.api_id = ?', params[:projectVersionId]).first!
          elsif params[:testId].present?
            Organization.active.joins(projects: :tests).where('project_tests.api_id = ?', params[:testId]).first!
          end
        end

        def serialization_options(results)
          # Make sure this will not process the retrieval of payloads multiple times
          return @serialization_options if @serialization_options

          records = results.kind_of?(Array) ? results : [ results ]

          # Serialization options with the payloads containing the SCM data
          @serialization_options = {
            with_scm: true_flag?(:withScm),
            payloads: TestPayload.with_scm_data.where('test_payloads.id in (?)', records.collect(&:test_payload_id))
          }
        end
      end

      get do
        authorize! TestResult, :index

        # Set the order clause
        rel = if params[:sort].present? && params[:sort] == 'runAt'
          TestResult.order('test_results.run_at desc')
        else
          TestResult.order('test_results.active desc, test_results.passed, test_results.name, test_results.id')
        end

        rel = rel.includes(:key, :category, :tags, :tickets, :runner, :test, { project_version: :project })

        # Filter by report
        if params[:reportId].present?
          rel = rel.joins(test_payload: :test_reports).where('test_reports.api_id = ?', params[:reportId].to_s)
        end

        # Filter by test
        if params[:testId].present?
          rel = rel.joins(:test).where('project_tests.api_id = ?', params[:testId])
        end

        # Filter by project
        if params[:projectId].present?
          rel = rel.joins(project_version: :project).where('projects.api_id = ?', params[:projectId])
        end

        # Filter by project version
        if params[:projectVersionId].present?
          if !params[:projectId].present?
            rel = rel.joins(:project_version)
          end

          rel = rel .where('project_versions.api_id = ?', params[:projectVersionId])
        end

        # Filter by runners
        if array_param?(:runnerIds)
          runners = User.select(:id).where('api_id IN (?)', params[:runnerIds].collect(&:to_s)).to_a
          rel = rel.where('test_results.runner_id in (?)', runners.collect(&:id))
        end

        rel = paginated rel

        serialize load_resources(rel)
      end
    end
  end
end

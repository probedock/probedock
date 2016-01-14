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
  class TestsApi < Grape::API
    namespace :tests do
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
          rel.includes :project
        end

        def serialization_options tests
          @serialization_options ||= {
            with_project: true_flag?(:withProject)
          }
        end
      end

      namespace '/:id' do
        helpers do
          def record
            @record ||= ProjectTest.where(api_id: params[:id].to_s).first!
          end

          def current_organization
            record.project.organization
          end
        end

        get do
          authenticate
          authorize! record, :show
          serialize record
        end
      end
    end
  end
end

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
  class ProjectsApi < Grape::API
    namespace :projects do
      helpers do
        def parse_project
          parse_object :name, :displayName, :description
        end

        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end

        def with_serialization_includes rel
          rel = rel.includes :organization
        end
      end

      post do
        authenticate!

        project = Project.new parse_project
        project.organization = Organization.where(api_id: params[:organizationId].to_s).first!
        authorize! project, :create

        ProjectValidations.validate project, validation_context, location_type: :json, raise_error: true

        create_record project
      end

      get do
        authenticate
        authorize! Project, :index

        rel = policy_scope(Project).order 'name ASC'

        rel = paginated rel do |rel|

          if current_organization.present?
            rel = rel.where organization_id: current_organization.id
          end

          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel = rel.where 'LOWER(api_id) LIKE ? OR LOWER(name) LIKE ?', term, term
          end

          if params[:name].present?
            rel = rel.where name: params[:name].to_s.downcase
          end

          rel
        end

        serialize load_resources(rel)
      end

      namespace '/:id' do
        helpers do
          def record
            @record ||= Project.where(api_id: params[:id].to_s).first!
          end

          def current_organization
            record.organization
          end
        end

        get do
          authenticate
          authorize! record, :show
          serialize record
        end

        patch do
          authenticate!
          authorize! record, :update
          update_record record, parse_project
        end
      end
    end
  end
end

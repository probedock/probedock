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
  class ProjectsApi < Grape::API
    namespace :projects do
      helpers do
        def parse_project
          parse_object :name, :displayName, :description
        end

        def current_organization
          if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
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

          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel = rel.where 'LOWER(api_id) LIKE ? OR LOWER(name) LIKE ?', term, term
          end

          if params[:name].present?
            rel = rel.where name: params[:name].to_s.downcase
          end

          rel
        end

        rel.to_a.collect{ |p| p.to_builder.attributes! }
      end

      namespace '/:id' do
        before do
          authenticate!
        end

        helpers do
          def current_project
            @current_project ||= Project.where(api_id: params[:id].to_s).first!
          end

          def current_organization
            current_project.organization
          end
        end

        get do
          authorize! current_project, :show
          current_project
        end

        patch do
          authorize! current_project, :update
          update_record current_project, parse_project
        end
      end
    end
  end
end

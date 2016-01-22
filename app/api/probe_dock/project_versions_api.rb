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
  class ProjectVersionsApi < Grape::API
    namespace :projectVersions do
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
      end

      get do
        authenticate
        authorize! ProjectVersion, :index

        rel = policy_scope(ProjectVersion).order 'projects.name ASC, created_at DESC'
        rel = rel.joins(:project)

        rel = paginated rel do |rel|

          if params[:projectId].present?
            rel = rel.where 'projects.api_id': params[:projectId]
          end

          if current_organization.present?
            rel = rel.where 'projects.organization_id': current_organization.id
          end

          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel = rel.where 'LOWER(name) LIKE ?', term, term
          end

          if params[:name].present?
            rel = rel.where name: params[:name].to_s.downcase
          end

          rel
        end

        serialize load_resources(rel)
      end
    end
  end
end

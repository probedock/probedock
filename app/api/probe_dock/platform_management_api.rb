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
  class PlatformManagementApi < Grape::API
    namespace :platformManagement do
      before do
        authenticate!
      end

      helpers do
        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.active.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.active.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      get :dbStats do
        authorize!(:platform_table_info, :index)
        serialize PlatformTableInfo.stats
      end

      get :orgStats do
        authorize!(:organization_table_info, :index)

        if params[:top].present?
          serialize(OrganizationTableInfo.top_stats(top: params[:top].to_i))
        else
          serialize(OrganizationTableInfo.top_stats(organization: @current_organization))
        end
      end
    end
  end
end

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
  class TagsApi < Grape::API
    namespace :tags do
      before do
        authenticate
      end

      helpers do
        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      get do
        authorize! :organization, :data

        rel = Tag

        rel = paginated rel do |rel|
          rel = rel.where organization_id: current_organization.id if current_organization
          rel
        end

        rel = rel.joins(:test_descriptions).group('tags.name, tags.organization_id, tags.created_at').order('count(distinct test_descriptions.test_id) desc').having('count(distinct test_descriptions.test_id) > 0')
        rel = rel.select('tags.name, tags.organization_id, tags.created_at, count(distinct test_descriptions.test_id) as tests_count')

        serialize load_resources(rel)
      end
    end
  end
end

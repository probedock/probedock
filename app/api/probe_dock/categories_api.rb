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
  class CategoriesApi < Grape::API
    namespace :categories do
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
      end

      get do
        authorize! :organization, :data

        rel = Category

        rel = paginated rel do |paginated_rel|
          if current_organization
            # filter by organization
            paginated_rel = paginated_rel.where 'categories.organization_id = ?', current_organization.id
          else
            # join with organizations to be able to sort by organization name
            paginated_rel = paginated_rel.joins :organization
          end

          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            paginated_rel = paginated_rel.where('LOWER(categories.name) LIKE ?', term)
          end

          paginated_rel
        end

        rel = rel.joins(:test_descriptions)
                 .select('categories.name, categories.organization_id, categories.created_at, count(distinct test_descriptions.test_id) as tests_count')
                 .having('count(distinct test_descriptions.test_id) > 0')

        if current_organization
          # order by descending tests_count, then the category name
          rel = rel.group('categories.id, categories.name, categories.organization_id, categories.created_at')
                   .order('count(distinct test_descriptions.test_id) desc, categories.name asc')
        else
          # order by organization name, then the rest
          rel = rel.group('categories.id, categories.name, categories.organization_id, categories.created_at, organizations.id, organizations.name')
                   .order('organizations.name, count(distinct test_descriptions.test_id) desc, categories.name asc')
        end

        serialize load_resources(rel)
      end
    end
  end
end

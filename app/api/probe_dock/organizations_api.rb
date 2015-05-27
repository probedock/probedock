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
  class OrganizationsApi < Grape::API

    namespace :organizations do

      helpers do
        def parse_organization
          parse_object :name, :displayName, :public
        end

        def serialization_options orgs

          unless @serialization_options
            @serialization_options = {
              with_roles: true_flag?(:withRoles)
            }

            if @serialization_options[:with_roles]
              organization_ids = Array.wrap(orgs).collect &:id
              @serialization_options[:current_user_memberships] = current_user.present? ? current_user.memberships.where(organization_id: organization_ids).to_a : []
            end
          end

          @serialization_options
        end
      end

      post do
        authenticate!
        authorize! Organization, :create

        data = parse_organization
        data[:public_access] = data.delete :public if data.key? :public

        organization = Organization.new data
        OrganizationValidations.validate organization, validation_context, location_type: :json, raise_error: true

        create_record organization
      end

      get do
        authenticate
        authorize! Organization, :index

        rel = policy_scope(Organization).order 'name ASC'

        rel = paginated rel do |rel|
          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel = rel.where 'LOWER(api_id) LIKE ? OR LOWER(name) LIKE ?', term, term
          end

          if params[:name].present?
            rel = rel.where normalized_name: params[:name].to_s.downcase
          end

          rel
        end

        serialize load_resources(rel)
      end

      namespace '/:id' do
        before do
          authenticate!
        end

        helpers do
          def record
            @record = Organization.where(api_id: params[:id].to_s).first!
          end
        end

        get do
          authorize! record, :show
          serialize record
        end

        patch do
          authorize! record, :update

          updates = parse_organization
          updates[:public_access] = updates.delete :public if updates.key? :public

          update_record record, updates
        end
      end
    end
  end
end

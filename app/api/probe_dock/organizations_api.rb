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
  class OrganizationsApi < Grape::API

    namespace :organizations do

      helpers do
        def parse_organization
          parse_object :name, :public
        end
      end

      post do
        authenticate!
        authorize! Organization, :create

        data = parse_organization
        organization = Organization.new name: data[:name], public_access: data[:public] == true
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
            rel.where 'LOWER(api_id) LIKE ? OR LOWER(name) LIKE ?', term, term
          else
            rel
          end
        end

        rel.to_a.collect{ |p| p.to_builder.attributes! }
      end

      namespace '/:id' do
        before do
          authenticate!
        end

        helpers do
          def current_organization
            if uuid? params[:id].to_s
              Organization.where(api_id: params[:id].to_s).first!
            else
              Organization.where(normalized_name: params[:id].to_s.downcase).first!
            end
          end
        end

        patch do
          org = current_organization
          authorize! org, :update

          update_record current_organization, parse_organization
        end

        namespace '/memberships' do
          helpers do
            def parse_member
              parse_object :userId, :email, :roles
            end
          end

          post do
            data = parse_member
            membership = Membership.new organization: current_organization
            authorize! membership, :create

            Membership.transaction do
              membership.organization_email = Email.where(address: data[:email]).first_or_create
              membership.user = data[:userId].present? ? User.where(api_id: data[:userId]).first : membership.organization_email.users.first
              membership.roles = data[:roles] if data[:roles].kind_of?(Array) && data[:roles].all?{ |r| r.kind_of?(String) }
              create_record membership
            end
          end
        end
      end
    end
  end
end

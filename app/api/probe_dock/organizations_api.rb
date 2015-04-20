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

      before do
        authenticate!
      end

      helpers do
        def parse_organization
          parse_object :name
        end
      end

      get do
        rel = Organization.order 'name ASC'

        rel = paginated Organization do |rel|
          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel.where 'LOWER(api_id) LIKE ? OR LOWER(name) LIKE ?', term, term
          else
            rel
          end
        end

        rel.to_a.collect{ |p| p.to_builder.attributes! }
      end

      post do
        organization = Organization.new parse_organization
        OrganizationValidations.validate organization, validation_context, location_type: :json, raise_error: true
        create_record organization
      end

      namespace '/:id' do

        helpers do
          def current_organization
            Organization.where(api_id: params[:id].to_s).first!
          end
        end

        patch do
          update_record current_organization, parse_organization
        end

        namespace '/members' do
          helpers do
            def parse_member
              parse_object :userId, :email
            end
          end

          post do
            data = parse_member
            user = User.where(api_id: data[:userId]).first!
            email = user.email

            member = OrganizationMember.new 
          end
        end
      end
    end
  end
end

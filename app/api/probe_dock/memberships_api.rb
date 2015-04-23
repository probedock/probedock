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
  class MembershipsApi < Grape::API
    namespace :memberships do
      helpers do
        def parse_membership
          parse_object :organizationId, :userId, :organizationEmail, :roles
        end

        def current_organization
          @current_organization ||= if params[:organizationId].present?
            Organization.where(api_id: params[:organizationId].to_s).first!
          elsif params[:organizationName].present?
            Organization.where(normalized_name: params[:organizationName].to_s.downcase).first!
          end
        end
      end

      post do
        authenticate!

        data = parse_membership
        membership = Membership.new organization: Organization.where(api_id: data[:organization_id]).first
        authorize! membership, :create

        Membership.transaction do
          membership.organization_email = Email.where(address: data[:organization_email]).first_or_create
          membership.user = data[:userId].present? ? User.where(api_id: data[:userId]).first : membership.organization_email.users.first
          membership.roles = data[:roles] if data[:roles].kind_of?(Array) && data[:roles].all?{ |r| r.kind_of?(String) }
          create_record membership
        end
      end

      get do
        authenticate
        authorize! Membership, :index

        rel = policy_scope(Membership.includes(:organization, :organization_email)).order 'created_at ASC'
        rel = rel.where organization: current_organization if current_organization.present?

        options = {
          with_organization: true_flag?(:withOrganization),
          with_user: true_flag?(:withUser)
        }

        if options[:with_user]
          rel = rel.includes user: :primary_email
        else
          rel = rel.includes :user
        end

        paginated(rel).to_a.collect{ |m| m.to_builder(options).attributes! }
      end

      namespace '/:id' do
        before do
          authenticate!
        end

        helpers do
          def record
            @record ||= Membership.where(api_id: params[:id].to_s).first!
          end
        end

        get do
          authorize! record, :show

          options = {
            with_organization: true_flag?(:withOrganization),
            with_user: true_flag?(:withUser)
          }

          record.to_builder(options).attributes!
        end

        patch do
          authorize! record, :update

          updates = parse_membership.slice :organization_email, :roles

          # FIXME: update organization email but only if user already has that email
          updates.delete :organization_email
          updates.delete :roles unless data[:roles].kind_of?(Array) && data[:roles].all?{ |r| r.kind_of?(String) }

          update_record record, updates
        end
      end
    end
  end
end

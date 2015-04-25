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

        def current_otp_record
          @current_otp_record ||= if params[:otp].present?
            rel = Membership.where('otp IS NOT NULL').where(otp: params[:otp].to_s).where('expires_at > ?', Time.now)
            rel = with_serialization_includes rel
            rel.first
          else
            nil
          end
        end

        def serialization_options
          @serialization_options ||= {
            with_organization: true_flag?(:withOrganization),
            with_user: true_flag?(:withUser)
          }
        end

        def with_serialization_includes rel

          rel = rel.includes :organization

          if serialization_options[:with_user]
            rel = rel.includes user: :primary_email
          else
            rel = rel.includes :user
          end

          rel
        end

        def serialize records
          if records.kind_of? Array
            records.to_a.collect{ |r| r.to_builder(serialization_options).attributes! }
          else
            records.to_builder(serialization_options).attributes!
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
          membership.roles = data[:roles] if data[:roles].kind_of?(Array) && data[:roles].all?{ |r| r.kind_of?(String) }

          if data[:user_id].present?
            authorize! membership, :set_user
            membership.user = User.where(api_id: data[:user_id]).first!
          end

          create_record membership do
            UserMailer.new_membership_email(membership).deliver_later
          end
        end
      end

      get do
        authenticate
        authorize! Membership, :index

        return serialize([ current_otp_record ].compact) if params.key? :otp

        rel = Membership.includes :organization, :organization_email
        rel = policy_scope(rel).order 'created_at ASC'

        rel = paginated rel do |rel|
          if params.key? :accepted
            rel = rel.where true_flag?(:accepted) ? 'memberships.user_id IS NOT NULL' : 'memberships.user_id IS NULL'
          end

          if current_user && params.key?(:mine)
            if current_organization.present? || current_user.try(:is?, :admin)
              condition = true_flag?(:mine) ? '=' : '!='
              rel = rel.joins(organization_email: :user).where("users.id #{condition} (?)", current_user.id)
            else
              rel = rel.none unless true_flag?(:mine)
            end
          end

          rel
        end

        options = {
          with_organization: true_flag?(:withOrganization),
          with_user: true_flag?(:withUser)
        }

        if options[:with_user]
          rel = rel.includes user: :primary_email
        else
          rel = rel.includes :user
        end

        rel.to_a.collect{ |m| m.to_builder(options).attributes! }
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

          updates = parse_membership.slice :organization_email, :roles, :user_id

          # FIXME: update organization email but only if user already has that email
          updates.delete :organization_email

          if updates[:roles].present?
            authorize! record, :set_roles
            updates.delete :roles unless updates[:roles].kind_of?(Array) && updates[:roles].all?{ |r| r.kind_of?(String) }
          end

          if updates[:user_id].present? && updates[:user_id] != record.user.try(:api_id)
            if record.user.blank? && updates[:user_id] == current_user.api_id
              authorize! record, :accept
            else
              authorize! record, :set_user
            end

            updates[:user] = User.where(api_id: updates[:user_id]).first!
          end

          update_record record, updates
        end

        delete do
          authorize! record, :destroy
          record.destroy
          status 204
          nil
        end
      end
    end
  end
end

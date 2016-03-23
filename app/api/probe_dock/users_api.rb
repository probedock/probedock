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
  class UsersApi < Grape::API

    namespace :users do
      helpers do
        def parse_user
          parse_object(:name, :primaryEmail, :active, :technical, :organizationId, :password, :passwordConfirmation)
        end

        def current_otp_record
          @current_otp_record ||= if params.key?(:membershipOtp)
            Membership.where('otp IS NOT NULL').where(otp: params[:membershipOtp].to_s).where('expires_at > ?', Time.now).first
          end
        end

        def with_serialization_includes rel
          rel = rel.includes(:memberships) if true_flag?(:withTechnicalMembership)
          rel = rel.includes(:organizations) if true_flag?(:withOrganizations)
          rel
        end

        def serialization_options *args
          {
            with_technical_membership: true_flag?(:withTechnicalMembership),
            with_organizations: true_flag?(:withOrganizations)
          }
        end
      end

      post do
        authenticate

        data = parse_user
        email = data.delete(:primary_email).try(:to_s).try(:downcase)
        org_id = data.delete(:organization_id)
        data[:password_confirmation] ||= ''

        user = User.new(data)
        user.active = true

        User.transaction do

          if data[:technical] && org_id.present?
            org = Organization.active.where(api_id: org_id).first
            user.memberships << Membership.new(user: user, organization: org)
          end

          authorize!(user, :create)

          if email.present? && email != current_otp_record.try(:organization_email).try(:address)
            authorize!(user, :update_email)
            user.primary_email = Email.where(address: email).first_or_initialize
            user.primary_email.user = user
          elsif current_otp_record.kind_of? Membership
            user.primary_email = current_otp_record.organization_email
            user.primary_email.user = user
            user.primary_email.active = true
          end

          create_record user do
            if current_otp_record.kind_of?(Membership)
              current_otp_record.user = user
              current_otp_record.save!
            end
          end
          # TODO: send registration e-mail
        end
      end

      get do
        authenticate
        authorize!(User, :index)

        users_rel = User.order('LOWER(users.name) ASC')

        users_rel = paginated(users_rel) do |paginated_rel|
          group = false

          if params[:email].present?
            email = Email.where(address: params[:email].to_s.downcase).first
            if email.present? && email.user_id.present?
              paginated_rel = paginated_rel.where('users.id = ?', email.user_id)
            else
              paginated_rel = paginated_rel.none
            end
          end

          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            paginated_rel = paginated_rel.joins(:emails).where('LOWER(users.name) LIKE ? OR emails.address like ?', term, term)
            group = true
          end

          if params[:name].present?
            paginated_rel = paginated_rel.where('users.name = ?', params[:name].to_s)
          end

          if params[:organizationId].present?
            organization = Organization.where(api_id: params[:organizationId].to_s).first!
            authorize!(organization, :show)
            paginated_rel = paginated_rel.joins(memberships: :organization).where('organizations.api_id = ?', params[:organizationId].to_s)
            group = true
          end

          @pagination_filtered_count = paginated_rel.count('distinct users.id')

          paginated_rel = paginated_rel.group('users.id') if group

          paginated_rel
        end

        serialize load_resources(users_rel)
      end

      namespace '/:id' do
        helpers do
          def record
            @record ||= load_resource!(User.where(api_id: params[:id].to_s))
          end

          def current_otp_record
            @current_otp_record ||= if params.key? :registrationOtp
              UserRegistration.where('otp IS NOT NULL').where(otp: params[:registrationOtp].to_s).where('expires_at > ?', Time.now).first
            end
          end
        end

        get do
          authenticate!
          authorize!(record, :show)
          serialize(record)
        end

        patch do
          authenticate
          authorize!(record, :update)

          User.transaction do

            updates = parse_user

            if updates.key?(:name)
              authorize!(record, :update_name)
              record.name = updates[:name]
            end

            if updates.key?(:active) && !!updates[:active] != record.active
              authorize!(record, :update_active)
              record.active = !!updates[:active]
            end

            # FIXME: only allow to set primary email if among existing emails
            if updates.key?(:primary_email) && updates[:primary_email] != record.primary_email.address
              authorize!(record, :update_email)
              record.primary_email = Email.where(address: updates[:primary_email].to_s.downcase).first_or_initialize
              record.primary_email.user = record
            end

            if updates.key?(:password)
              authorize!(record, :update_password)
              record.password = updates[:password]
              record.password_confirmation = updates[:password_confirmation] || ''
            end

            update_record record
          end
        end

        delete do
          authenticate!
          authorize!(record, :destroy)
          record.destroy
          status 204
          nil
        end
      end
    end
  end
end

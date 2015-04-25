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
  class UsersApi < Grape::API

    namespace :users do

      helpers do
        def parse_user_for_creation
          parse_object :name, :primaryEmail, :password, :passwordConfirmation
        end

        def parse_user_for_update
          parse_object :name, :primaryEmail, :active, :password, :passwordConfirmation
        end

        def current_otp_record
          @current_otp_record ||= if params.key? :membershipOtp
            Membership.where('otp IS NOT NULL').where(otp: params[:membershipOtp].to_s).where('expires_at > ?', Time.now).first
          end
        end
      end

      post do
        authenticate
        authorize! User, :create

        data = parse_user_for_creation
        email = data.delete(:primary_email).try(:to_s).try(:downcase)
        data[:password_confirmation] ||= ''

        User.transaction do
          user = User.new data

          if email.present? && email != current_otp_record.try(:organization_email).try(:address)
            authorize! user, :set_email
            user.primary_email = Email.where(address: email).first_or_initialize
            user.primary_email.user = user
          elsif current_otp_record.kind_of? Membership
            user.primary_email = current_otp_record.organization_email
            user.primary_email.user = user
            user.primary_email.active = true
          end

          create_record user do
            if current_otp_record.kind_of? Membership
              current_otp_record.user = user
              current_otp_record.save!
            end
          end
          # TODO: send registration e-mail
        end
      end

      get do
        authenticate
        authorize! User, :index

        rel = User.order 'name ASC'

        rel = paginated rel do |rel|
          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel = rel.where 'LOWER(users.name) LIKE ?', term
          end

          if params[:name].present?
            rel = rel.where 'users.name = ?', params[:name].to_s
          end

          rel
        end

        rel.to_a.collect{ |u| u.to_builder.attributes! }
      end

      namespace '/:id' do
        before do
          authenticate!
        end

        helpers do
          def user_resource
            @user_resource ||= User.where(api_id: params[:id].to_s).first!
          end
        end

        get do
          authorize! user_resource, :show
          user_resource
        end

        patch do
          authorize! user_resource, :update
          update_record user_resource, parse_user_for_update do |user,updates|

            user.name = updates[:name] if updates.key? :name
            user.active = !!updates[:active] if updates.key? :active
            user.primary_email = Email.where(address: updates[:primary_email]).first_or_initialize if updates.key?(:primary_email) && updates[:primary_email] != user.primary_email.try(:address)
            user.primary_email.user = user

            if updates.key? :password
              user.password = updates[:password]
              user.password_confirmation = updates[:password_confirmation] || ''
            end

            user.save
          end
        end

        delete do
          authorize! user_resource, :destroy
          user_resource.destroy
          status 204
        end
      end
    end
  end
end

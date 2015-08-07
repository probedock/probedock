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
  class RegistrationsApi < Grape::API
    namespace :registrations do
      helpers do
        def parse_registration
          data = parse_object :user, :organization
          data[:user] = parse_object(data[:user] || {}, :name, :primaryEmail)
          data[:organization] = parse_object(data[:organization] || {}, :name, :displayName, :public) if data.key? :organization
          data
        end

        def with_serialization_includes rel
          rel.includes :user, :organization
        end

        def current_otp_record
          @current_otp_record = if params.key? :otp
            UserRegistration.where('otp IS NOT NULL').where(otp: params[:otp].to_s).where('expires_at > ?', Time.now).first
          end
        end
      end

      post do
        data = parse_registration

        primary_email = data[:user].delete(:primary_email).to_s
        data[:user][:primary_email] = Email.where(address: primary_email).first_or_initialize if primary_email

        if data.key? :organization
          data[:organization][:public_access] = data[:organization].delete :public if data[:organization].key? :public
        end

        registration = UserRegistration.new
        registration.user = User.new data[:user]
        registration.organization = Organization.new data[:organization] if data.key? :organization

        authorize! registration, :create

        UserRegistration.transaction do
          create_record registration do
            UserMailer.new_registration_email(registration).deliver_later
          end
        end
      end

      get do
        authenticate
        authorize! UserRegistration, :index

        rel = policy_scope UserRegistration

        rel = paginated rel do |rel|
          # no filters for now
          rel
        end

        rel = rel.order 'created_at DESC'

        serialize load_resources(rel)
      end

      namespace '/:id' do
        helpers do
          def record
            @record ||= load_resource!(UserRegistration.where(api_id: params[:id].to_s))
          end
        end
      end
    end
  end
end

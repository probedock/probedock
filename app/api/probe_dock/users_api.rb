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

      before do
        authenticate!
      end

      helpers do

        def parse_user_for_creation
          parse_object :name, :email, :password, :passwordConfirmation
        end

        def parse_user_for_update
          parse_object :name, :email, :active, :password, :passwordConfirmation
        end
      end

      post do
        authorize! User, :create

        data = parse_user_for_creation
        email = data.delete :email
        data[:password_confirmation] ||= ''

        User.transaction do
          user = User.new data
          user.primary_email = Email.where(address: email).first_or_create

          create_record user
        end
      end

      get do
        authorize! User, :index

        rel = User.order 'name ASC'

        rel = paginated rel do |rel|
          if params[:search].present?
            term = "%#{params[:search].downcase}%"
            rel.where 'LOWER(users.name) LIKE ?', term
          else
            rel
          end
        end

        rel.to_a.collect{ |u| u.to_builder.attributes! }
      end

      namespace '/:id' do

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
            user.primary_email = Email.where(address: updates[:email]).first_or_create if updates[:email] != user.email.try(:address) if updates.key? :email

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

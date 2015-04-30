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
require 'json/jwt'

module ProbeDock
  class API < Grape::API

    format :json
    version 'v1', using: :accept_version_header

    cascade false
    rescue_from :all do |e|

      if e.kind_of? Errapi::ValidationFailed
        next Rack::Response.new([ JSON.dump(e.context.serialize) ], 422, { "Content-Type" => "application/json" }).finish
      end

      if Rails.env != 'production'
        puts e.message
        puts e.backtrace.join("\n")
      end

      code, message = case e
      when ProbeDock::Errors::Unauthorized
        [ 401, nil ]
      when Pundit::NotAuthorizedError, ProbeDock::Errors::Forbidden
        [ 403, 'You are not authorized to perform this action.' ]
      when ActiveRecord::RecordNotFound
        [ 404, 'No resource was found matching the request URI.' ]
      else
        [ 500, 'An internal server error occurred.' ]
      end

      Rack::Response.new([ JSON.dump({ errors: [ { message: message || e.message } ] }) ], code, { "Content-Type" => "application/json" }).finish
    end

    helpers ApiAuthenticationHelper
    helpers ApiAuthorizationHelper
    helpers ApiPaginationHelper
    helpers ApiParamsHelper
    helpers ApiResourceHelper

    get :ping do
      'pong'
    end

    mount AccessTokensApi
    mount AuthenticationApi
    mount MembershipsApi
    mount MetricsApi
    mount OrganizationsApi
    mount PayloadsApi
    mount ProjectsApi
    mount ReportsApi
    mount TagsApi
    mount TestKeysApi
    mount UsersApi
  end
end

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

# Utility methods to handle authentication, available to all API classes mounted in `ProbeDock::API`.
module ApiAuthenticationHelper

  # Attempts to authenticate the user by looking for a valid JWT bearer token
  # in the Authorization header or in the `authToken` query parameter.
  #
  # Returns true if authentication was successful, false otherwise (no error is raised).
  # Use this method when authentication is optional.
  def authenticate
    @auth_token = auth_token_from_header || auth_token_from_params
    return false if @auth_token.blank?

    begin
      @auth_claims = JSON::JWT.decode(@auth_token, Rails.application.secrets.jwt_secret)
    rescue JSON::JWT::Exception
      false
    end

    true
  end

  # Ensures that the user is authenticated.
  # Uses `#authenticate`, then raises an error if no valid JWT bearer token was found.
  # Use this method when authentication is mandatory.
  def authenticate!
    authenticate
    raise ProbeDock::Errors::Unauthorized.new 'Missing credentials' if @auth_token.blank?
    raise ProbeDock::Errors::Unauthorized.new 'Invalid credentials' if @auth_claims.blank? || current_user.blank?
  end

  # Returns the authenticated user.
  # This requires you to have called `#authenticate` or `#authenticate!` beforehand.
  def current_user
    @current_user ||= @auth_claims.blank? ? nil : User.where(api_id: @auth_claims['iss']).includes(memberships: :organization).first
  end

  # Returns the value of the `authToken` query parameter, or nil if it's not present.
  def auth_token_from_params
    params[:authToken]
  end

  # Returns the bearer token sent in the Authorization header, if present.
  def auth_token_from_header
    if m = headers['Authorization'].try(:match, /\ABearer (.+)\Z/)
      m[1]
    else
      nil
    end
  end
end

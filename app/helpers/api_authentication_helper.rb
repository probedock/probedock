# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
module ApiAuthenticationHelper

  def auth_token_from_params
    params[:authToken]
  end

  def auth_token_from_header
    if m = headers['Authorization'].try(:match, /\ABearer (.+)\Z/)
      m[1]
    else
      nil
    end
  end

  def authenticate!

    @auth_token = auth_token_from_header || auth_token_from_params
    raise ROXCenter::Errors::Unauthorized.new 'Missing credentials' if @auth_token.blank?

    # TODO: use another secret for signing auth tokens
    begin
      @auth_claims = JSON::JWT.decode(@auth_token, Rails.application.secrets.secret_key_base)
    rescue JSON::JWT::Exception
      raise ROXCenter::Errors::Unauthorized.new 'Invalid credentials'
    end
  end

  def current_user
    @current_user ||= User.where(email: @auth_claims['iss']).first!
  end
end

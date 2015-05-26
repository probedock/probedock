# Copyright (c) 2015 Probe Dock
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
  class AuthenticationApi < Grape::API
    post :authentication do

      authorization = request.headers['Authorization']
      raise ProbeDock::Errors::Unauthorized.new 'Missing credentials' unless authorization.present?
      raise ProbeDock::Errors::Unauthorized.new 'Malformed HTTP Basic Authorization header' unless m = authorization.match(/\ABasic (.*)\Z/)

      credentials = Base64.decode64 m[1]
      parts = credentials.split ':'
      raise ProbeDock::Errors::Unauthorized.new 'Malformed HTTP Basic credentials' unless parts.length == 2

      user = if parts[0].match(/\@/).present?
        User.joins(:emails).where(emails: { address: parts[0], active: true }).first
      else
        User.where(name: parts[0]).first
      end

      # TODO: protect against timing attacks
      raise ProbeDock::Errors::Unauthorized.new 'Invalid credentials' unless user && user.authenticate(parts[1])

      {
        token: user.generate_auth_token,
        user: serialize(user, current_user: user)
      }
    end
  end
end

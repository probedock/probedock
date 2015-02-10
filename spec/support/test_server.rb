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

module TestServerHelper

  def visit_test_server *args
    visit test_server_url(*args)
  end

  def test_server_url *args
    URI.join(*(args.unshift(test_server_root_url)).join('/')).to_s
  end

  def test_server_post user, url, body, options = {}

    headers = options[:headers] || {}
    headers['ContentType'] ||= 'application/json'

    api_key = user.api_keys.where(active: true).first
    headers['Authorization'] ||= %/ProbeDockApiKey id="#{api_key.identifier}" secret="#{api_key.shared_secret}"/

    HTTParty.post url, { body: body, headers: headers }
  end

  def test_server_root_url
    "http://localhost:#{RSpec.configuration.test_server_port}"
  end
end

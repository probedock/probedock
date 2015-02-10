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
require 'spec_helper'

describe "API authentication", probe_dock: { tags: :unit } do

  let(:user){ create :user }

  it "should not authenticate clients without credentials", probe_dock: { key: '168e19242af3' } do
    get api_path, {}, { 'HTTP_ACCEPT' => 'application/hal+json' }
    assert_response :unauthorized
  end

  it "should authenticate clients with the RoxApiKey authorization scheme", probe_dock: { key: 'f3c29dcf6302' } do
    key = user.api_keys.first
    get api_path, {}, { 'HTTP_AUTHORIZATION' => %/RoxApiKey id="#{key.identifier}" secret="#{key.shared_secret}"/ }
    assert_response :success
  end

  it "should authenticate clients with an API key in url parameters", probe_dock: { key: '333808c1cf65' } do
    key = user.api_keys.first
    get api_path, api_key_id: key.identifier, api_key_secret: key.shared_secret
    assert_response :success
  end

  it "should not authenticate clients with an inactive API key", probe_dock: { key: '42def337de2b' } do
    key = user.api_keys.first
    key.update_attribute :active, false
    get api_path, {}, { 'HTTP_AUTHORIZATION' => %/RoxApiKey id="#{key.identifier}" secret="#{key.shared_secret}"/ }
    assert_response :unauthorized
  end
end

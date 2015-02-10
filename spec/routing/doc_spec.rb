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
require 'spec_helper'

describe 'Documentation routing' do

  it(nil, probe_dock: { key: 'c4a7b4aa1655' }){ should route(:get, '/doc/changelog').to(controller: :doc, action: :changelog) }
  it(nil, probe_dock: { key: 'fbba467fb8cc' }){ should route(:get, '/doc/clients').to(controller: :doc, action: :clients) }

  # API Documentation
  it(nil, probe_dock: { key: 'acf4b92578f6' }){ should route(:get, '/doc/api').to(controller: :doc, action: :api_overview) }
  it(nil, probe_dock: { key: 'c9a11a0b430e' }){ should route(:get, '/doc/api/browser').to(controller: :doc, action: :api_browser) }

  it(nil, probe_dock: { key: 'cfdf6450dab1' }){ should route(:get, '/doc/api/res').to(controller: :doc, action: :api_resources) }
  context "API resources", probe_dock: { key: '166e97854ebd', grouped: true } do
    %w(test-payloads).each do |res|
      it{ should route(:get, "/doc/api/res/#{res}").to(controller: :doc, action: :api_resource, name: res) }
    end
  end

  it(nil, probe_dock: { key: 'f0ddd023ff20' }){ should route(:get, '/doc/api/rels').to(controller: :doc, action: :api_relations) }
  context "API relations", probe_dock: { key: '31dd66460bf8', grouped: true } do
    %w(rt:test-payloads).each do |rel|
      it{ should route(:get, "/doc/api/rels/#{rel}").to(controller: :doc, action: :api_relation, name: rel) }
    end
  end

  it(nil, probe_dock: { key: '784ea2f35c11' }){ should route(:get, '/doc/api/media').to(controller: :doc, action: :api_media_types) }
  context "API media types", probe_dock: { key: 'b64b891ae2be', grouped: true } do
    %w(errors payload-v1).each do |media_type|
      it{ should route(:get, "/doc/api/media/#{media_type}").to(controller: :doc, action: :api_media_type, name: media_type) }
    end
  end
end

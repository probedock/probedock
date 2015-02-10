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

describe 'API routing' do

  it(nil, probe_dock: { key: 'dec51511b761' }){ should route(:get, '/api').to(controller: 'api/api', action: :index) }
  it(nil, probe_dock: { key: 'aececbc85d07' }){ should route(:get, '/api/projects').to(controller: 'api/projects', action: :index) }
  it(nil, probe_dock: { key: 'ed1802698baf' }){ should route(:post, '/api/projects').to(controller: 'api/projects', action: :create) }
  it(nil, probe_dock: { key: '5736a920ee15' }){ should route(:put, '/api/projects/42').to(controller: 'api/projects', action: :update, id: '42') }
  it(nil, probe_dock: { key: '11bdc396c773' }){ should route(:get, '/api/test_keys').to(controller: 'api/test_keys', action: :index) }
  it(nil, probe_dock: { key: 'd191eb7c4e3e' }){ should route(:post, '/api/test_keys').to(controller: 'api/test_keys', action: :create) }
  it(nil, probe_dock: { key: '57f2d52bfaa5' }){ should route(:delete, '/api/test_keys').to(controller: 'api/test_keys', action: :auto_release) }
  it(nil, probe_dock: { key: '12a97fdaca46' }){ should route(:post, '/api/test_payloads').to(controller: 'api/test_payloads', action: :create) }
  it(nil, probe_dock: { key: '4a003aabf324' }){ should route(:get, '/api/test_payloads/42').to(controller: 'api/test_payloads', action: :show, id: '42') }
  it(nil, probe_dock: { key: '4d9d38d044c3' }){ should route(:get, '/api/test_results/42').to(controller: 'api/test_results', action: :show, id: '42') }
  it(nil, probe_dock: { key: 'b32a2d48e495' }){ should route(:get, '/api/test_runs').to(controller: 'api/test_runs', action: :index) }
  it(nil, probe_dock: { key: '33adcc1d02dc' }){ should route(:get, '/api/tests').to(controller: 'api/tests', action: :index) }
  it(nil, probe_dock: { key: '2e12d8ee3818' }){ should route(:get, '/api/tests/42/results').to(controller: 'api/tests', action: :results, id: '42') }
  it(nil, probe_dock: { key: '9c5b9e041869' }){ should route(:put, '/api/tests/42/deprecation').to(controller: 'api/tests', action: :deprecate, id: '42') }
  it(nil, probe_dock: { key: '8bd0ce3f3e61' }){ should route(:delete, '/api/tests/42/deprecation').to(controller: 'api/tests', action: :undeprecate, id: '42') }
  it(nil, probe_dock: { key: '89059466db61' }){ should route(:get, '/api/users').to(controller: 'api/users', action: :index) }
  it(nil, probe_dock: { key: '074b0fcbc78f' }){ should route(:get, '/api/purges').to(controller: 'api/purges', action: :index) }
  it(nil, probe_dock: { key: '0f65f7465ee8' }){ should route(:post, '/api/purges').to(controller: 'api/purges', action: :create) }

  # API keys
  it(nil, probe_dock: { key: '520ba7b406a4' }){ should route(:get, '/api_keys').to(controller: :account_api_keys, action: :index) }
  it(nil, probe_dock: { key: '52a6cb41e3e6' }){ should route(:post, '/api_keys').to(controller: :account_api_keys, action: :create) }
  it(nil, probe_dock: { key: '0b401215d7d1' }){ should route(:get, '/api_keys/42').to(controller: :account_api_keys, action: :show, id: '42') }
  it(nil, probe_dock: { key: '6771a7c23d97' }){ should route(:put, '/api_keys/42').to(controller: :account_api_keys, action: :update, id: '42') }
  it(nil, probe_dock: { key: '02e61af7a80e' }){ should route(:delete, '/api_keys/42').to(controller: :account_api_keys, action: :destroy, id: '42') }

  # Legacy API below
  LEGACY_API_ROUTE_OPTIONS = { format: 'json' }

  it(nil, probe_dock: { key: 'b30da10c514b' }){ should route(:post, '/api/v1/links').to(controller: :links, action: :create) }
  it(nil, probe_dock: { key: '34a7fbd4b862' }){ should route(:put, '/api/v1/links/42').to(controller: :links, action: :update, id: 42) }
  it(nil, probe_dock: { key: 'ed3a81c02b01' }){ should route(:delete, '/api/v1/links/42').to(controller: :links, action: :destroy, id: 42) }
  it(nil, probe_dock: { key: 'bcf5d93a4a86' }){ should route(:post, '/api/v1/link_templates').to(controller: :link_templates, action: :create) }
  it(nil, probe_dock: { key: '93aa6c8a111a' }){ should route(:put, '/api/v1/link_templates/42').to(controller: :link_templates, action: :update, id: 42) }
  it(nil, probe_dock: { key: '81eb9b5be64a' }){ should route(:delete, '/api/v1/link_templates/42').to(controller: :link_templates, action: :destroy, id: 42) }
  it(nil, probe_dock: { key: 'a37d18f62f9d' }){ should route(:get, '/api/v1/metrics/breakdown/authors').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :author_breakdown) }
  it(nil, probe_dock: { key: '1569b9a07f48' }){ should route(:get, '/api/v1/metrics/breakdown/categories').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :category_breakdown) }
  it(nil, probe_dock: { key: '565818ce6faa' }){ should route(:get, '/api/v1/metrics/breakdown/projects').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :project_breakdown) }
  # This test must be written differently because multiple routes match this controller action (see https://github.com/thoughtbot/shoulda-matchers/issues/225).
  it(nil, probe_dock: { key: '7a549977839a' }){ expect({ get: '/api/v1/settings' }).to route_to(LEGACY_API_ROUTE_OPTIONS.merge controller: 'settings', action: 'show') }
  it(nil, probe_dock: { key: 'a3ee1bd68466' }){ should route(:put, '/api/v1/settings').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :settings, action: :update) }
  it(nil, probe_dock: { key: 'bdd8ec3cbd3e' }){ should route(:get, '/api/v1/tags/cloud').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :tags, action: :cloud) }
end

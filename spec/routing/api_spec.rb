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
require 'spec_helper'

describe 'API routing' do

  it(nil, rox: { key: 'dec51511b761' }){ should route(:get, '/api').to(controller: 'api/api', action: :index) }
  it(nil, rox: { key: '12a97fdaca46' }){ should route(:post, '/api/payloads').to(controller: 'api/payloads', action: :create) }
  it(nil, rox: { key: 'aececbc85d07' }){ should route(:get, '/api/projects').to(controller: 'api/projects', action: :index) }
  it(nil, rox: { key: 'ed1802698baf' }){ should route(:post, '/api/projects').to(controller: 'api/projects', action: :create) }
  it(nil, rox: { key: '5736a920ee15' }){ should route(:put, '/api/projects/42').to(controller: 'api/projects', action: :update, id: '42') }
  it(nil, rox: { key: '11bdc396c773' }){ should route(:get, '/api/test_keys').to(controller: 'api/test_keys', action: :index) }
  it(nil, rox: { key: 'd191eb7c4e3e' }){ should route(:post, '/api/test_keys').to(controller: 'api/test_keys', action: :create) }
  it(nil, rox: { key: '57f2d52bfaa5' }){ should route(:delete, '/api/test_keys').to(controller: 'api/test_keys', action: :auto_release) }

  # API keys
  it(nil, rox: { key: '520ba7b406a4' }){ should route(:get, '/api_keys').to(controller: :account_api_keys, action: :index) }
  it(nil, rox: { key: '52a6cb41e3e6' }){ should route(:post, '/api_keys').to(controller: :account_api_keys, action: :create) }
  it(nil, rox: { key: '0b401215d7d1' }){ should route(:get, '/api_keys/42').to(controller: :account_api_keys, action: :show, id: '42') }
  it(nil, rox: { key: '6771a7c23d97' }){ should route(:put, '/api_keys/42').to(controller: :account_api_keys, action: :update, id: '42') }
  it(nil, rox: { key: '02e61af7a80e' }){ should route(:delete, '/api_keys/42').to(controller: :account_api_keys, action: :destroy, id: '42') }

  # Legacy API below
  LEGACY_API_ROUTE_OPTIONS = { format: 'json' }

  it(nil, rox: { key: '532660fe44b3' }){ should route(:get, '/api/v1/account/tests').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :accounts, action: :tests_page) }
  it(nil, rox: { key: 'b30da10c514b' }){ should route(:post, '/api/v1/links').to(controller: :links, action: :create) }
  it(nil, rox: { key: '34a7fbd4b862' }){ should route(:put, '/api/v1/links/42').to(controller: :links, action: :update, id: 42) }
  it(nil, rox: { key: 'ed3a81c02b01' }){ should route(:delete, '/api/v1/links/42').to(controller: :links, action: :destroy, id: 42) }
  it(nil, rox: { key: 'bcf5d93a4a86' }){ should route(:post, '/api/v1/link_templates').to(controller: :link_templates, action: :create) }
  it(nil, rox: { key: '93aa6c8a111a' }){ should route(:put, '/api/v1/link_templates/42').to(controller: :link_templates, action: :update, id: 42) }
  it(nil, rox: { key: '81eb9b5be64a' }){ should route(:delete, '/api/v1/link_templates/42').to(controller: :link_templates, action: :destroy, id: 42) }
  it(nil, rox: { key: 'a37d18f62f9d' }){ should route(:get, '/api/v1/metrics/breakdown/authors').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :author_breakdown) }
  it(nil, rox: { key: '1569b9a07f48' }){ should route(:get, '/api/v1/metrics/breakdown/categories').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :category_breakdown) }
  it(nil, rox: { key: '565818ce6faa' }){ should route(:get, '/api/v1/metrics/breakdown/projects').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :metrics, action: :project_breakdown) }
  it(nil, rox: { key: '8a0755e79548' }){ should route(:get, '/api/v1/projects/42/tests_page').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :projects, action: :tests_page, id: '42') }
  it(nil, rox: { key: 'b32a2d48e495' }){ should route(:get, '/api/v1/runs').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :test_runs, action: :page) }
  # This test must be written differently because multiple routes match this controller action (see https://github.com/thoughtbot/shoulda-matchers/issues/225).
  it(nil, rox: { key: '7a549977839a' }){ { get: '/api/v1/settings' }.should route_to(LEGACY_API_ROUTE_OPTIONS.merge controller: 'settings', action: 'show') }
  it(nil, rox: { key: 'a3ee1bd68466' }){ should route(:put, '/api/v1/settings').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :settings, action: :update) }
  it(nil, rox: { key: 'bdd8ec3cbd3e' }){ should route(:get, '/api/v1/tags/cloud').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :tags, action: :cloud) }
  it(nil, rox: { key: '33adcc1d02dc' }){ should route(:get, '/api/v1/tests').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :test_infos, action: :page) }
  it(nil, rox: { key: '2e12d8ee3818' }){ should route(:get, '/api/v1/tests/42/results').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :test_infos, action: :results_page, id: '42') }
  it(nil, rox: { key: '82bfebcf0d7e' }){ should route(:get, '/api/v1/tests/42/results/chart').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :test_infos, action: :results_chart, id: '42') }
  it(nil, rox: { key: '4d9d38d044c3' }){ should route(:get, '/api/v1/results/42').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :test_results, action: :show, id: 42) }
  it(nil, rox: { key: '89059466db61' }){ should route(:get, '/api/v1/users').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :users, action: :page) }
  it(nil, rox: { key: '5026cba6a993' }){ should route(:get, '/api/v1/users/42/tests').to(LEGACY_API_ROUTE_OPTIONS.merge controller: :users, action: :tests_page, id: 42) }
end

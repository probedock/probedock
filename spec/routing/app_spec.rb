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

describe 'App routing' do
  APP_ROUTE_OPTIONS = { locale: 'en' }

  #it{ should route(:get, '/').to(controller: :home, action: :index) }
  it(nil, rox: { key: '5cc16476592c' }){ should route(:get, '/data/status').to(controller: :data, action: :status) }
  it(nil, rox: { key: '17ee5765c3d0' }){ should route(:get, '/data/general').to(controller: :data, action: :general) }
  it(nil, rox: { key: 'a5aa58aa7a3e' }){ should route(:get, '/data/current_test_metrics').to(controller: :data, action: :current_test_metrics) }
  it(nil, rox: { key: '8bcd3f90f524' }){ should route(:get, '/data/latest_test_runs').to(controller: :data, action: :latest_test_runs) }
  it(nil, rox: { key: 'd13ca3b0830b' }){ should route(:get, '/data/test_counters').to(controller: :data, action: :test_counters) }
  it(nil, rox: { key: 'd9a01140cf1c' }){ should route(:post, '/data/test_counters').to(controller: :data, action: :test_counters) }
  it(nil, rox: { key: 'e21abf07237b' }){ should route(:post, '/maintenance').to(controller: :home, action: :maintenance) }
  it(nil, rox: { key: 'ffd07068f8a1' }){ should route(:delete, '/maintenance').to(controller: :home, action: :maintenance) }
  it(nil, rox: { key: '07fb3795c62f' }){ should route(:get, '/ping').to(controller: :home, action: :ping) }

  it(nil, rox: { key: 'd31909fa2e05' }){ should route(:get, '/en').to(APP_ROUTE_OPTIONS.merge controller: :home, action: :index) }
  it(nil, rox: { key: 'bfe93538488b' }){ should route(:get, '/en/account').to(APP_ROUTE_OPTIONS.merge controller: :accounts, action: :show) }
  it(nil, rox: { key: '76a45c6250ad' }){ should route(:put, '/en/account/settings').to(APP_ROUTE_OPTIONS.merge controller: :accounts, action: :update_settings) }
  it(nil, rox: { key: '7328eddd1d72' }){ should route(:get, '/en/go/project').to(APP_ROUTE_OPTIONS.merge controller: :go, action: :project) }
  it(nil, rox: { key: '0fdb63d43c36' }){ should route(:get, '/en/go/run').to(APP_ROUTE_OPTIONS.merge controller: :go, action: :run) }
  it(nil, rox: { key: '87bf98a672be' }){ should route(:get, '/en/metrics').to(APP_ROUTE_OPTIONS.merge controller: :metrics, action: :index) }
  it(nil, rox: { key: '251c38ec02ab' }){ should route(:get, '/en/projects').to(APP_ROUTE_OPTIONS.merge controller: :projects, action: :index) }
  it(nil, rox: { key: '796ada05066d' }){ should route(:get, '/en/projects/42').to(APP_ROUTE_OPTIONS.merge controller: :projects, action: :show, id: '42') }
  it(nil, rox: { key: '2f4dac9841fb' }){ should route(:get, '/en/settings').to(APP_ROUTE_OPTIONS.merge controller: :settings, action: :show) }
  it(nil, rox: { key: 'dc2db17cfd5d' }){ should route(:get, '/en/status').to(APP_ROUTE_OPTIONS.merge controller: :home, action: :status) }
  it(nil, rox: { key: 'ca901bcb554a' }){ should route(:get, '/en/tags').to(APP_ROUTE_OPTIONS.merge controller: :tags, action: :index) }
  it(nil, rox: { key: 'fbbc237d3753' }){ should route(:get, '/en/tests').to(APP_ROUTE_OPTIONS.merge controller: :test_infos, action: :index) }
  it(nil, rox: { key: '32f0b8d13a53' }){ should route(:get, '/en/tests/42').to(APP_ROUTE_OPTIONS.merge controller: :test_infos, action: :show, id: 42) }
  it(nil, rox: { key: 'a1df6cba5382' }){ should route(:get, '/en/runs').to(APP_ROUTE_OPTIONS.merge controller: :test_runs, action: :index) }
  it(nil, rox: { key: 'c7e41ec8ac17' }){ should route(:get, '/en/runs/42').to(APP_ROUTE_OPTIONS.merge controller: :test_runs, action: :show, id: 42) }
  it(nil, rox: { key: '51eb9ac64dd3' }){ should route(:get, '/en/runs/42/previous').to(APP_ROUTE_OPTIONS.merge controller: :test_runs, action: :previous, id: 42) }
  it(nil, rox: { key: 'fbde78225701' }){ should route(:get, '/en/runs/42/next').to(APP_ROUTE_OPTIONS.merge controller: :test_runs, action: :next, id: 42) }
  it(nil, rox: { key: 'd9d0d910cd0a' }){ should route(:get, '/en/users').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :index) }
  it(nil, rox: { key: '81843bae5e3b' }){ should route(:get, '/en/users/new').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :new) }
  it(nil, rox: { key: '9f0db46268aa' }){ should route(:get, '/en/user/abc').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :show, id: 'abc') }
  it(nil, rox: { key: '769d2c3cbfb8' }){ should route(:post, '/en/user').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :create) }
  it(nil, rox: { key: 'd9256786220d' }){ should route(:get, '/en/user/abc/edit').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :edit, id: 'abc') }
  it(nil, rox: { key: '862a1c1317ee' }){ should route(:put, '/en/user/abc').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :update, id: 'abc') }
  it(nil, rox: { key: '77d3e6627fba' }){ should route(:delete, '/en/user/abc').to(APP_ROUTE_OPTIONS.merge controller: :users, action: :destroy, id: 'abc') }
end

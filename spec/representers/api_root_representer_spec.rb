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

describe ApiRootRepresenter, probe_dock: { tags: :unit } do

  let(:ability){ double can?: false }
  subject{ ApiRootRepresenter.new(ability).serializable_hash }

  it(nil, probe_dock: { key: '9407aafe238d' }){ should hyperlink_to('self', api_uri, title: t('api.root.title')) }
  it(nil, probe_dock: { key: '76b0f021ae87' }){ should hyperlink_to('help', uri(:doc_api_overview), type: media_type(:markdown), title: t('api.root.help')) }
  it(nil, probe_dock: { key: '9482fb379866' }){ should hyperlink_to('version-history', uri(:doc_changelog), type: media_type(:markdown), title: t('api.root.changelog')) }
  it(nil, probe_dock: { key: '2059b885b71d' }){ should hyperlink_to('v1:apiKeys', uri(:api_keys)) }
  it(nil, probe_dock: { key: '3faa828ac00c' }){ should hyperlink_to('v2:projects', api_uri(:projects), title: t('api.root.projects')) }
  it(nil, probe_dock: { key: '3b9a095eee4d' }){ should hyperlink_to('v1:tests', "#{api_uri(:tests)}{?authors[]*,projects[]*}", templated: true) }
  it(nil, probe_dock: { key: '6acd0a937bfb' }){ should hyperlink_to('v1:testKeys', api_uri(:test_keys), title: t('api.root.test_keys')) }
  it(nil, probe_dock: { key: 'c0ed17d1b681' }){ should hyperlink_to('v1:testPayloads', api_uri(:test_payloads), title: t('api.root.payloads'), type: media_type(:probe_dock_payload_v1)) }
  it(nil, probe_dock: { key: '171a470dc050' }){ should hyperlink_to('v1:testRuns', "#{api_uri(:test_runs)}{?latest,groups[]*,runners[]*}", title: t('api.root.test_runs'), templated: true) }
  it(nil, probe_dock: { key: '823435b09a08' }){ should hyperlink_to('v1:users', api_uri(:users), title: t('api.root.users')) }
  it(nil, probe_dock: { key: '75c900a99394' }){ should have_only_properties(appVersion: ProbeDock::Application::VERSION) }
  it(nil, probe_dock: { key: 'd94e0a55674a' }){ should have_curie(name: 'v1', templated: true, href: "#{uri(:doc_api_relation, name: 'v1')}:root:{rel}") }

  # legacy
  it(nil, probe_dock: { key: 'a5afe4dd2af1' }){ should hyperlink_to('v1:projects', api_uri(:legacy_projects)) }
  it(nil, probe_dock: { key: 'dc7c4d4eaf94' }){ should hyperlink_to('v1:test-keys', api_uri(:legacy_test_keys)) }
  it(nil, probe_dock: { key: '691e9cae0eca' }){ should hyperlink_to('v1:test-payloads', api_uri(:test_payloads), type: media_type(:payload_v1)) }

  it "should not hyperlink to v1:purges", probe_dock: { key: 'e00c27ec7d59' } do
    expect(subject['_links']['v1:purges']).to be_nil
  end

  describe "for an admin" do
    let(:ability){ double can?: true }
    it(nil, probe_dock: { key: '8ded6f08728e' }){ should hyperlink_to('v1:purges', api_uri(:purges), title: t('api.root.purges')) }
  end
end

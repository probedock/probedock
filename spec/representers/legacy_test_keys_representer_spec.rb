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

describe LegacyTestKeysRepresenter, probe_dock: { tags: :unit } do

  let(:user){ create :user }
  let(:projects){ Array.new(2){ create :project } }
  let(:test_keys){ Array.new(3){ |i| create :test_key, user: user, project: projects[i % 2] } }
  let(:options){ { total: 5, data: test_keys } }
  subject{ described_class.new(OpenStruct.new(options)).serializable_hash }

  it(nil, probe_dock: { key: '193150eaff1d' }){ should hyperlink_to('self', api_uri(:legacy_test_keys)) }
  it(nil, probe_dock: { key: '2f02fc1d10bb' }){ should have_embedded('v1:test-keys', test_keys.collect{ |k| TestKeyRepresenter.new(k).serializable_hash }) }
  it(nil, probe_dock: { key: '59187950847d' }){ should have_only_properties(total: 5) }
  it(nil, probe_dock: { key: 'a7edd65d01ab' }){ should have_curie(name: 'v1', templated: true, href: "#{uri(:doc_api_relation, name: 'v1')}:testKeys:{rel}") }

  context "with a page number" do
    let(:options){ super().merge page: 1 }

    it(nil, probe_dock: { key: 'a93a6f8ae6a4' }){ should have_only_properties(total: 5, page: 1) }
  end
end

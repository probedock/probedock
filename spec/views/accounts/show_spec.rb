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

describe 'accounts/show', probe_dock: { tags: :unit } do

  let(:user){ create :user }
  before(:each){ allow(view).to receive(:current_user){ user } }
  subject{ render; rendered }
  let(:page) { Capybara::Node::Simple.new(subject) }

  it "should show user information", probe_dock: { key: '03821f9cbb97' } do
    expect(subject).to include(user.name)
    expect(subject).to include(user.email)
  end

  it "should inject the keyGenerator module", probe_dock: { key: '58f4d5b208ea' } do
    config = { foo: 'bar' }
    assign(:key_generator_config, config)
    sel = 'div[data-module="keyGenerator"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq(config.to_json)
  end

  it "should inject the apiKeysTable module", probe_dock: { key: '452d45ce102d' } do
    sel = 'div[data-module="apiKeysTable"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to be_nil
  end

  it "should inject the testsTable module", probe_dock: { key: 'b596c3856bdf' } do
    assign :tests_table_config, tests_table_config = { foo: 'bar' }
    sel = 'div[data-module="testsTable"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq(tests_table_config.to_json)
  end

  context 'with unknown users' do

    it "should not show the e-mail", probe_dock: { key: '3a1ab173bc4a' } do
      user.update_columns email: nil
      expect(subject).not_to include(User.human_attribute_name(:email))
    end
  end
end

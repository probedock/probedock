# Copyright (c) 2012-2013 Lotaris SA
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

describe 'accounts/show', rox: { tags: :unit } do

  let(:user){ create :user }
  before(:each){ view.stub(:current_user){ user } }
  subject{ render; rendered }
  let(:page) { Capybara::Node::Simple.new(subject) }

  it "should show user information", rox: { key: '03821f9cbb97' } do
    subject.should include(user.name)
    subject.should include(user.email)
  end

  it "should inject the keyGenerator module", rox: { key: '58f4d5b208ea' } do
    config = { foo: 'bar' }
    assign(:key_generator_config, config)
    sel = 'div[data-module="keyGenerator"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq(config.to_json)
  end

  it "should inject the apiKeysTable module", rox: { key: '452d45ce102d' } do
    sel = 'div[data-module="apiKeysTable"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq({ path: api_keys_path }.to_json)
  end

  it "should inject the testsTable module", rox: { key: 'b596c3856bdf' } do
    test_search_config = { foo: 'bar' }
    assign(:test_search_config, test_search_config)
    sel = 'div[data-module="testsTable"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq({ path: tests_legacy_api_account_path, search: test_search_config }.to_json)
  end

  context 'with unknown users' do

    let(:user){ create :unknown_user }

    it "should not show the e-mail", rox: { key: '3a1ab173bc4a' } do
      subject.should_not include(User.human_attribute_name(:email))
    end
  end
end

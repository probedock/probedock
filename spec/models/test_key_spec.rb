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

describe TestKey, probe_dock: { tags: :unit } do

  context "#free?" do

    it "should return the value of free", probe_dock: { key: 'f80dc7bba1b7' } do
      user = create :user
      expect(create(:test_key, user: user, free: false).free?).to be(false)
      expect(create(:test_key, user: user, free: true).free?).to be(true)
    end
  end

  context ".for_projects_and_keys" do

    let(:user){ create :user }
    let(:projects){ Array.new(2){ create :project } }
    let(:keys){ Array.new(7){ |i| create :test_key, user: user, project: projects[i % 2] } }

    it "should return the test keys with the specified values for the specified projects", probe_dock: { key: '4ea2b3f0ab04' } do
      keys_by_project = keys[0, 5].inject({}){ |memo,k| (memo[k.project.api_id] ||= []) << k.key; memo }
      expect(TestKey.for_projects_and_keys(keys_by_project)).to match_array(keys[0, 5])
    end
  end

  context "key" do

    # TODO: test automatic increase of key size
    it "should be 4 characters long", probe_dock: { key: '9a8335194eb5' } do
      10.times{ expect(TestKey.generate_random_key(1).length).to eq(4) }
    end

    it "should be unique", probe_dock: { key: '0fe5f1cf41d3' } do

      keys = [ '0123456789ab', 'ab0123456789', 'cd0123456789' ]
      allow(TestKey).to receive(:generate_random_key){ keys.shift }

      project = create :project
      create :test_key, key: '0123456789ab', user: create(:user), project: project
      create :test_key, key: 'ab0123456789', user: create(:user), project: project
      expect(TestKey.new_random_key(project.id)).to eq('cd0123456789')
    end

    it "should be automatically generated", probe_dock: { key: '408c231c1648' } do
      expect(create(:test_key).key).to be_present
    end
  end

  context "validations" do
    it(nil, probe_dock: { key: '2203deb2d4a7' }){ should validate_presence_of(:project) }
    it(nil, probe_dock: { key: '91bdf868399c' }){ should have_and_belong_to_many(:test_payloads) }
  end

  context "associations" do
    it(nil, probe_dock: { key: '426fc1e0e854' }){ should belong_to(:user) }
    it(nil, probe_dock: { key: '72a817a8e20e' }){ should belong_to(:project) }
    it(nil, probe_dock: { key: 'f8253f179295' }){ should have_one(:test).class_name('ProjectTest').with_foreign_key(:key_id) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '2fc3e9920ebf' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: 'aeac4b7f7091' }){ should have_db_column(:key).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probe_dock: { key: 'b8348c80380a' }){ should have_db_column(:free).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, probe_dock: { key: 'ef12acb9b301' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: 'f839734b03ad' }){ should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: 'bb651aec1f4b' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '114bc07dc8fe' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'c9470ed4275e' }){ should have_db_index([ :key, :project_id ]).unique(true) }
  end
end

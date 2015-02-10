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

describe Api::TestKeysController, rox: { tags: :unit } do
  include MaintenanceHelpers
  
  let(:user){ create :user }
  let(:project){ create :project }

  describe "#create" do

    it "should create the requested number of keys for a project and user", rox: { key: 'aa411bcb252e' } do

      expect{ generate_keys n: 5 }.to change(TestKey, :count).by(5)
      expect(response.success?).to be(true)

      keys = TestKey.order('created_at ASC').to_a
      expect(keys.all?{ |k| k.user == user && k.project == project }).to be(true)
      expect(MultiJson.load(response.body)).to eq(TestKeysRepresenter.new(OpenStruct.new(total: 5, data: keys)).serializable_hash)
    end

    it "should indicate the total number of keys for the user", rox: { key: '76a35139b094' } do
      other_project = create :project
      3.times{ create :test_key, user: user, project: other_project }
      expect{ generate_keys n: 5 }.to change(TestKey, :count).by(5)
      expect(MultiJson.load(response.body)['total']).to eq(8)
    end

    it "should create one key if no number is specified", rox: { key: '2eac146513ce' } do
      expect{ generate_keys }.to change(TestKey, :count).by(1)
    end

    it "should not accept a number of keys under 1 or over 25", rox: { key: '096562525cc1' } do
      [ -2, 0, 26, 100 ].each do |n|
        expect{ generate_keys n: n }.not_to change(TestKey, :count)
        check_api_errors [ { name: 'number_of_keys_invalid', message: Regexp.new("got #{n}") } ]
      end
    end

    it "should not accept a request without a project API ID", rox: { key: 'f58497f7589d' } do
      expect{ generate_keys({ n: 1 }, MultiJson.dump({})) }.not_to change(TestKey, :count)
      check_api_errors [ { name: 'project_api_id_missing', path: '/projectApiId', message: Regexp.new("API") } ]
    end

    it "should not accept a request with an unknown project API ID", rox: { key: 'c89c530f4cf9' } do
      expect{ generate_keys({ n: 1 }, MultiJson.dump({ 'projectApiId' => '000000000000' })) }.not_to change(TestKey, :count)
      check_api_errors [ { name: 'project_api_id_unknown', path: '/projectApiId', message: Regexp.new('000000000000') } ]
    end

    it "should save the last project and requested number of keys", rox: { key: '4f6ae80d86a1' } do

      settings = user.settings
      expect(settings.last_test_key_project).to be_nil
      expect(settings.last_test_key_number).to be_nil

      generate_keys n: 5
      expect(response.success?).to be(true)

      settings.reload
      expect(settings.last_test_key_project).to eq(project)
      expect(settings.last_test_key_number).to eq(5)

      another_project = create :project
      generate_keys({ n: 3 }, generation_request_body(another_project))

      settings.reload
      expect(settings.last_test_key_project).to eq(another_project)
      expect(settings.last_test_key_number).to eq(3)
    end

    it "should return a 503 response when in maintenance mode", rox: { key: 'e27209fb845a' } do
      set_maintenance_mode
      expect{ generate_keys n: 5 }.not_to change(TestKey, :count)
      expect(response.status).to eq(503)
    end
  end

  describe "#destroy" do
    let(:projects){ [ project, create(:project) ] }
    let!(:unfree_keys){ Array.new(3){ |i| create :test_key, user: user, project: projects[(i % 2 - 1).abs], free: false } }

    it "should not do anything when the user has no free keys", rox: { key: 'b244b60361f4' } do
      expect{ release_keys }.not_to change(TestKey, :count)
      expect(response.status).to eq(204)
      expect(user.tap(&:reload).test_keys).to match_array(unfree_keys)
    end

    describe "with free keys" do
      let!(:free_keys){ Array.new(3){ |i| create :test_key, user: user, project: projects[i % 2], free: true } }

      it "should delete free keys of the current user", rox: { key: '07a7dcc7c3b7' } do
        expect(user.test_keys).to have(6).items
        expect(user.free_test_keys).to have(3).items
        expect{ release_keys }.to change(TestKey, :count).by(-3)
        expect(response.status).to eq(204)
        expect(user.tap(&:reload).test_keys).to match_array(unfree_keys)
      end

      it "should return a 503 response when in maintenance mode", rox: { key: '4f967c31c27a' } do
        set_maintenance_mode
        expect{ release_keys }.not_to change(TestKey, :count)
        expect(response.status).to eq(503)
      end
    end
  end

  describe "#index" do

    def parse_response options = {}
      api_get user, api_legacy_test_keys_path(options)
      HashWithIndifferentAccess.new MultiJson.load(response.body)
    end

    # data
    let!(:test_keys){ Array.new(5){ create :test_key, user: user, project: project } }

    # inaccessible data (to check scoping)
    let!(:other_user){ create :other_user }
    let!(:other_test_keys){ Array.new(3){ create :test_key, user: other_user, project: project } }

    # table resource test configuration
    let(:records){ test_keys }
    let(:record_converter){ ->(k){ k.key } }
    let(:embedded_rel){ 'v1:test-keys' }
    let(:embedded_converter){ ->(k){ k[:value] } }

    describe "table resource", rox: { key: '691dee34def5', grouped: true } do
      it_should_behave_like "a table resource", {
        representation: {
          sort: :createdAt,
          records: ->(records){ records.sort_by &:created_at },
          representer: TestKeysRepresenter
        },
        pagination: {
          sort: :createdAt,
          sorted: ->(records){ records.sort_by &:created_at }
        },
        sorting: {
          createdAt: ->(records){ records.sort_by &:created_at }
        },
        quick_search: [
          { name: :value, block: ->(records){ k = records.sample; { term: k.key, sort: :createdAt, results: [ k ] } } }
        ]
      }
    end
  end

  private

  def generate_keys params = {}, body = generation_request_body
    api_post user, :api_test_keys, body, params
  end

  def generation_request_body p = project
    MultiJson.dump 'projectApiId' => p.api_id
  end

  def release_keys
    api_delete user, :api_test_keys
  end
end

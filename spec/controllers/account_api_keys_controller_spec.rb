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

describe AccountApiKeysController, rox: { tags: :unit } do
  let(:user){ create :user }

  it "should not authenticate clients with api keys", rox: { key: '02331e558e38' } do
    key = user.api_keys.first
    request.env['HTTP_AUTHORIZATION'] = %/RoxApiKey id="#{key.identifier}" secret="#{key.shared_secret}"/
    get :index
    assert_response :redirect
  end

  context "when signed in" do

    before(:each){ sign_in user }

    it "should create an api key for the current user", rox: { key: 'e39606279c85' } do
      existing_key = user.api_keys.first
      post :create
      user.api_keys.should have(2).items
      response.success?.should be_true
      Oj.load(response.body).should == ApiKeyRepresenter.new((user.api_keys - [ existing_key ]).first).serializable_hash
    end

    it "should show a detailed api key", rox: { key: '3c157dc6c596' } do
      key = user.api_keys.first
      get :show, id: key.identifier
      response.success?.should be_true
      Oj.load(response.body).should == ApiKeyRepresenter.new(key, detailed: true).serializable_hash
    end

    it "should not give access to other users' keys", rox: { key: '417d9239cbbe' } do
      other_key = create(:other_user).api_keys.first
      get :show, id: other_key.identifier
      assert_response :not_found
    end

    it "should update an api key", rox: { key: '6444cd3c2e91' } do
      key = user.api_keys.first
      put :update, id: key.identifier, account_api_key: { active: false }
      response.success?.should be_true
      key.tap(&:reload).active.should be_false
      Oj.load(response.body).should == ApiKeyRepresenter.new(key).serializable_hash
    end

    it "should destroy an api key", rox: { key: '41cc158c1010' } do
      key = user.api_keys.first
      lambda{ delete :destroy, id: key.identifier }.should change(ApiKey, :count).by(-1)
      response.status.should eq(204)
      user.tap(&:reload).api_keys.should be_empty
    end

    context "#index" do

      def parse_response options = {}
        get :index, options
        HashWithIndifferentAccess.new Oj.load(response.body)
      end

      # data
      let(:usage_counts){ [ 3, 6, 4, 1 ] }
      let(:created_ats){ k = user.api_keys.first; [ -1, 2, 4, 3 ].collect{ |n| k.created_at + n.days } }
      let(:last_used_ats){ [ 1, 3, 6, 2 ].collect{ |n| Time.now - n.days } }
      let!(:additional_api_keys){ Array.new(4){ create :api_key, user: user, usage_count: usage_counts.shift, created_at: created_ats.shift, last_used_at: last_used_ats.shift } }

      # inaccessible data (to check scoping)
      let!(:other_user){ create :other_user }
      let!(:other_api_keys){ Array.new(3){ create :api_key, user: other_user } }

      # table resource test configuration
      let(:records){ user.api_keys }
      let(:record_converter){ ->(k){ k.identifier } }
      let(:embedded_rel){ 'v1:api-keys' }
      let(:embedded_converter){ ->(k){ k[:id] } }

      context "table resource", rox: { key: '4caf4e56251a', grouped: true } do
        it_should_behave_like "a table resource", {
          representation: {
            sort: :id,
            records: ->(records){ records.sort_by &:identifier },
            representer: ApiKeysRepresenter
          },
          pagination: {
            sort: :id,
            sorted: ->(records){ records.sort_by &:identifier }
          },
          sorting: {
            id: ->(records){ records.sort_by &:identifier },
            usageCount: ->(records){ records.sort_by &:usage_count },
            createdAt: ->(records){ records.sort_by &:created_at },
            lastUsedAt: ->(records){ records.sort_by{ |k| k.last_used_at || 1.year.ago } }
          },
          quick_search: [
            { name: :identifier, block: ->(records){ k = records.sample; { term: k.identifier, sort: :id, results: [ k ] } } }
          ]
        }
      end
    end
  end
end

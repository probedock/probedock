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

RSpec.describe Api::PurgesController, type: :controller do
  let(:user){ create :user }

  before :each do
    ResqueSpec.reset!
  end

  describe "#create" do

    describe "access", probe_dock: { key: 'a9a00a6c7494', grouped: true } do
      it_should_behave_like "an admin API resource", ->(*args){ get :index }
    end

    describe "when logged in as an administrator" do
      let(:user){ create :admin_user }
      before(:each){ sign_in user }

      it "should create a purge action", probe_dock: { key: '909fd7651d00' } do

        now = Time.now
        allow(Time).to receive(:now).and_return(now)

        expect do
          post :create, MultiJson.dump(dataType: 'tags')
        end.to change(PurgeAction, :count).by(1)

        expect(response.status).to eq(201)
        expect(MultiJson.load(response.body)).to eq(PurgeActionRepresenter.new(PurgeAction.order('created_at desc').first).serializable_hash)
      end

      it "should not allow to create a purge without a data type", probe_dock: { key: '1cf56ddd97ce' } do
        expect do
          post :create, MultiJson.dump({})
        end.not_to change(PurgeAction, :count)
        expect(response.status).to eq(400)
      end

      it "should work during maintenance mode", probe_dock: { key: 'f8e23918e034' } do
        set_maintenance_mode
        post :create, MultiJson.dump(dataType: 'tags')
        expect(response.status).to eq(201)
      end
    end
  end

  describe "#index" do

    describe "access", probe_dock: { key: 'b682cbd05d18', grouped: true } do
      it_should_behave_like "an admin API resource", ->(*args){ get :index }
    end

    describe "with the info parameter" do
      let(:user){ create :admin_user }
      before(:each){ sign_in user }
      before :each do
        allow(Resque).to receive(:size).and_return(42)
      end
      let! :tags_purges do
        [
          create(:completed_purge_action, data_type: 'tags', created_at: 7.days.ago),
          create(:completed_purge_action, data_type: 'tags', created_at: 3.days.ago),
          create(:completed_purge_action, data_type: 'tags', created_at: 2.days.ago)
        ]
      end
      let! :tickets_purges do
        [
          create(:completed_purge_action, data_type: 'tickets', created_at: 1.day.ago),
          create(:purge_action, data_type: 'tickets', created_at: 2.minutes.ago)
        ]
      end

      it "should return purge information", probe_dock: { key: 'b0ffe4dd8166' } do

        get :index, info: true
        expect(response.status).to eq(200)

        expected_purge_actions = [
          tags_purges.last,
          PurgeAction.new(data_type: 'testPayloads'),
          PurgeAction.new(data_type: 'testRuns'),
          tickets_purges.last
        ]

        expected_data = OpenStruct.new(data: expected_purge_actions, total: 4)

        body = MultiJson.load response.body
        expect(body).to eq(PurgeActionsRepresenter.new(expected_data, info: true).serializable_hash)
      end
    end
  end
end

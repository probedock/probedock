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

describe SettingsController do
  let(:user){ create :user }
  before(:each){ sign_in user }

  it "should not authorize normal users", probe_dock: { key: '9c54f0e0bacd' } do
    expect{ get :show }.to raise_error(CanCan::AccessDenied)
    expect{ put :update, setting: { ticketing_system_url: 'http://example.com' } }.to raise_error(CanCan::AccessDenied)
  end

  describe "for administrators" do
    let(:user){ create :admin }

    describe "#show" do

      it "should return the settings as JSON", probe_dock: { key: '358d0dee856e' } do
        get :show, format: :json
        expect(response.success?).to be(true)
        expect(MultiJson.load(response.body)).to eq(HashWithIndifferentAccess.new(Settings::App.get.serializable_hash))
      end
    end

    describe "#update" do
      let(:new_values) do
        {
          ticketing_system_url: 'http://example.com',
          reports_cache_size: 42,
          tag_cloud_size: 24,
          test_outdated_days: 66,
          test_payloads_lifespan: 11,
          test_runs_lifespan: 77
        }
      end

      it "should update the settings", probe_dock: { key: '394fc08c0929' } do
        put :update, setting: new_values
        expect(response.success?).to be(true)
        expect(MultiJson.load(response.body)).to eq(HashWithIndifferentAccess.new(new_values))
      end

      it "should ignore the update if any value is invalid", probe_dock: { key: '5606b1076e8b' } do
        new_values[:test_outdated_days] = -2
        put :update, setting: new_values
        expect(response.success?).to be(true)
        expect(MultiJson.load(response.body)).to eq(HashWithIndifferentAccess.new(Settings::App.get.serializable_hash))
      end

      it "should return a 503 response when in maintenance mode", probe_dock: { key: 'dadc01cfce0c' } do
        old_values = Settings::App.get.serializable_hash
        set_maintenance_mode
        put :update, setting: new_values
        expect(response.status).to eq(503)
        expect(Settings::App.get.tap(&:reload).serializable_hash).to eq(old_values)
      end
    end
  end
end

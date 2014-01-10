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

describe SettingsController do
  let(:user){ create :user }
  before(:each){ sign_in user }

  it "should not authorize normal users", rox: { key: '9c54f0e0bacd' } do
    expect{ get :show }.to raise_error(CanCan::AccessDenied)
    expect{ put :update, setting: { ticketing_system_url: 'http://example.com' } }.to raise_error(CanCan::AccessDenied)
  end

  describe "for administrators" do
    let(:user){ create :admin }

    describe "#show" do

      describe "HTML" do
        subject{ assigns }
        before(:each){ get :show, locale: I18n.default_locale }

        it "should set the window title", rox: { key: '15975da9031a' } do
          expect(subject[:window_title]).to eq([ t('common.title'), t('settings.show.title') ])
        end

        it "should fetch status data", rox: { key: '1c2b01c71d98' } do
          expect(subject[:status_data]).to eq(StatusData.compute)
        end

        it "should set the test counters configuration", rox: { key: '58b561514050' } do
          expect(subject[:test_counters_config]).to eq(data: TestCountersData.compute)
        end
      end

      describe "JSON" do

        it "should return the settings as JSON", rox: { key: '358d0dee856e' } do
          get :show, format: :json
          expect(response.success?).to be_true
          expect(Oj.load(response.body)).to eq(HashWithIndifferentAccess.new(Settings::App.get.serializable_hash))
        end
      end
    end

    describe "#update" do
      let(:new_values){ { ticketing_system_url: 'http://example.com', reports_cache_size: 42, tag_cloud_size: 24, test_outdated_days: 66 } }

      it "should update the settings", rox: { key: '394fc08c0929' } do
        put :update, setting: new_values
        expect(response.success?).to be_true
        expect(Oj.load(response.body)).to eq(HashWithIndifferentAccess.new(new_values))
      end

      it "should ignore the update if any value is invalid", rox: { key: '5606b1076e8b' } do
        new_values[:test_outdated_days] = -2
        put :update, setting: new_values
        expect(response.success?).to be_true
        expect(Oj.load(response.body)).to eq(HashWithIndifferentAccess.new(Settings::App.get.serializable_hash))
      end

      it "should return a 503 response when in maintenance mode", rox: { key: 'dadc01cfce0c' } do
        old_values = Settings::App.get.serializable_hash
        set_maintenance_mode
        put :update, setting: new_values
        expect(response.status).to eq(503)
        expect(Settings::App.get.tap(&:reload).serializable_hash).to eq(old_values)
      end
    end
  end
end

# Copyright (c) 2012-2014 Lotaris SA
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

describe Settings, rox: { tags: :unit } do
  SETTINGS_CACHE_KEY = 'cache:json:settings:app'

  let(:sample_settings){
    {
      ticketing_system_url: 'foo',
      reports_cache_size: 24,
      tag_cloud_size: 66,
      test_outdated_days: 32,
      test_payloads_lifespan: 11
    }
  }
  
  context ".app" do

    it "should return the app settings", rox: { key: 'd5fe308a81f7' } do
      Settings::App.first.update_attributes sample_settings
      expect(Settings.app).to eq(OpenStruct.new(sample_settings))
    end

    it "should cache the app settings", rox: { key: 'e90799259d27' } do
      expect($redis.exists(SETTINGS_CACHE_KEY)).to be(false)
      expect(Settings).to query_the_database(1.times).when_calling(:app)
      expect($redis.exists(SETTINGS_CACHE_KEY)).to be(true)
      expect(Settings).not_to query_the_database.when_calling(:app)
    end

    it "should used the given cached settings", rox: { key: '738c72ac035d' } do
      cached = double contents: sample_settings
      expect(Settings).not_to receive(:cache)
      expect(Settings).not_to query_the_database.when_calling(:app).with(cached)
      expect(Settings.app(cached)).to eq(OpenStruct.new(sample_settings))
    end
  end
end

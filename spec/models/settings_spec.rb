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

describe Settings, probe_dock: { tags: :unit } do

  let(:sample_settings){
    {
      ticketing_system_url: 'foo',
      reports_cache_size: 24,
      tag_cloud_size: 66,
      test_outdated_days: 32,
      test_payloads_lifespan: 11,
      test_runs_lifespan: 77
    }
  }

  context ".app" do
    it "should return the app settings", probe_dock: { key: 'd5fe308a81f7' } do
      Settings::App.first.update_attributes sample_settings
      expect(Settings.app).to eq(OpenStruct.new(sample_settings))
    end
  end
end

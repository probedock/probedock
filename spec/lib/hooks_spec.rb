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

describe RoxHook do
  let(:hooks){
    [
      TagsData, StatusData, GeneralData, LatestTestRunsData, LatestProjectsData, Settings::App, CurrentTestMetricsData,
      CacheReportJobForUi, CountDeprecationJob, CountTestsJob, PurgeAllJob, PurgeTagsJob, PurgeTestPayloadsJob, PurgeTestRunsJob, PurgeTicketsJob
    ]
  }

  it "should have all hooks registered", probe_dock: { key: 'c0f472250ab4' } do
    expect(described_class.hooks).to match_array(hooks)
  end

  it "should forward application events to all hooks", probe_dock: { key: '5e0afd9d3056' } do
    hooks.each{ |hook| expect(hook).to receive(:fire).with('event', foo: 'bar') }
    Rails.application.events.fire 'event', foo: 'bar'
  end
end

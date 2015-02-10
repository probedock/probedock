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

describe CacheReportJobForUi do
  CACHE_REPORT_JOB_FOR_UI_QUEUE = 'cache:high'

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{CACHE_REPORT_JOB_FOR_UI_QUEUE} queue", probe_dock: { key: 'eae775aaeb15' } do
    expect(described_class.instance_variable_get('@queue')).to eq(CACHE_REPORT_JOB_FOR_UI_QUEUE)
  end

  it "should enqueue a job on the api:payload event", probe_dock: { key: '05538f390a7e' } do
    test_run_double = double id: 42
    expect(described_class).to receive(:enqueue).with(test_run_double)
    described_class.fire 'api:payload', double(processed_test_run: double(test_run: test_run_double))
  end

  describe ".enqueue" do
    
    it "should enqueue a job for a test run", probe_dock: { key: 'd870c3722fc3' } do
      described_class.enqueue double(id: 42)
      expect(described_class).to have_queued(42, cache: :force).in(CACHE_REPORT_JOB_FOR_UI_QUEUE)
      expect(described_class).to have_queue_size_of(1)
    end

    it "should log the test run id", probe_dock: { key: '784a1af21716' } do
      expect(Rails.logger).to receive(:debug).with(/caching report.*42/i)
      described_class.enqueue double(id: 42)
    end
  end

  describe ".perform" do
    
    it "should get the report from the cache with the specified options", probe_dock: { key: '8463e717a4fe' } do
      expect(TestRun.reports_cache).to receive(:get).with(42, HashWithIndifferentAccess.new(foo: 'bar'))
      described_class.perform 42, foo: 'bar'
    end
  end
end

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

describe CacheReportJobForWarmup do
  CACHE_REPORT_JOB_FOR_WARMUP_QUEUE = 'cache:low'

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{CACHE_REPORT_JOB_FOR_WARMUP_QUEUE} queue", rox: { key: '6ea675178596' } do
    expect(described_class.instance_variable_get('@queue')).to eq(CACHE_REPORT_JOB_FOR_WARMUP_QUEUE)
  end

  describe ".enqueue" do
    
    it "should enqueue a job for a test run", rox: { key: 'e5bcce4fa4fe' } do
      described_class.enqueue double(id: 42)
      expect(described_class).to have_queued(42, cache: :force).in(CACHE_REPORT_JOB_FOR_WARMUP_QUEUE)
      expect(described_class).to have_queue_size_of(1)
    end
  end

  describe ".perform" do
    
    it "should get the report from the cache with the specified options", rox: { key: 'fcd92ec7970b' } do
      expect(TestRun.reports_cache).to receive(:get).with(42, HashWithIndifferentAccess.new(foo: 'bar'))
      described_class.perform 42, foo: 'bar'
    end
  end
end

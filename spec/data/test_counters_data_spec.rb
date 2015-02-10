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

describe TestCountersData, probe_dock: { tags: :unit } do
  subject{ described_class }
  let(:user){ create :user }

  before :each do
    ResqueSpec.reset!
  end

  describe ".queue_size" do

    it "should return the size of the test counters queue", probe_dock: { key: '1289a59187fc' } do

      expect(TestCountersData.queue_size).to eq(0)
      expect(TestCountersData.queue_size).to eq(Resque.size(CountTestsJob.queue))

      without_resque_spec do
        fill_test_counters_queue 3
        expect(TestCountersData.queue_size).to eq(3)
        expect(TestCountersData.queue_size).to eq(Resque.size(CountTestsJob.queue))
      end
    end
  end

  describe ".compute" do

    it "should make only one call to redis", probe_dock: { key: '021b87f91735' } do
      expect{ subject.compute }.to change{ number_of_redis_calls }.by(1)
    end

    it "should return information about test counters processing when nothing is happening", probe_dock: { key: 'e4601616e590' } do
      expect(subject.compute).to eq(jobs: 0, recomputing: false, remainingResults: 0, preparing: false, totalCounters: 0)
    end

    it "should return information about test counters processing", probe_dock: { key: '88378b19085a' } do

      fill_test_counters_queue 3
      $redis.set TestCounter.cache_key(:recomputing), true
      $redis.set TestCounter.cache_key(:preparing), true
      $redis.set TestCounter.cache_key(:remaining_results), 42
      allow(TestCounter).to receive(:count).and_return(24)

      expect(subject.compute).to eq(jobs: 3, recomputing: true, remainingResults: 42, preparing: true, totalCounters: 24)
    end
  end

  describe ".fingerprint" do
    let!(:first_fingerprint){ described_class.fingerprint }
    subject{ first_fingerprint }

    it "should not change across calls", probe_dock: { key: 'e83ff91a23d9' } do
      expect(subject).to eq(fingerprint)
    end

    it "should change if the size of the test counters queue changes", probe_dock: { key: 'b4ad75476ad1' } do
      fill_test_counters_queue 3
      expect(subject).not_to eq(fingerprint)
    end

    it "should change depending on whether test counters are recomputing", probe_dock: { key: '4841e56f1574' } do
      $redis.set TestCounter.cache_key(:recomputing), true
      expect(subject).not_to eq(fingerprint)
    end

    it "should change depending on whether test counters are preparing", probe_dock: { key: '782cb2ff295a' } do
      $redis.set TestCounter.cache_key(:preparing), true
      expect(subject).not_to eq(fingerprint)
    end

    it "should change if the number of remaining results changes", probe_dock: { key: '6aaafadf4fab' } do
      $redis.set TestCounter.cache_key(:remaining_results), 42
      expect(subject).not_to eq(fingerprint)
    end

    def fingerprint
      described_class.fingerprint
    end
  end

  def fill_test_counters_queue n
    fill_resque_queue CountTestsJob.queue, *Array.new(n){ |i| i }
  end
end

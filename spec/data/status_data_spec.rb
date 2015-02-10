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

describe StatusData do
  subject{ described_class }
  STATUS_DATA_CACHE_KEY = 'cache:status'

  it "should return cached dates", rox: { key: 'ea29408c00a8' } do
    t1, t2, t3, t4 = 1.day.ago.to_ms, 2.days.ago.to_ms, 3.days.ago.to_ms, 4.days.ago.to_ms
    $redis.hmset STATUS_DATA_CACHE_KEY, 'last_api_payload', t1, 'last_test_deprecation', t2, 'last_test_counters', t3, 'last_purge', t4
    expect(subject.compute).to include(lastApiPayload: t1, lastTestDeprecation: t2, lastTestCounters: t3, lastPurge: t4)
  end

  it "should set missing dates to now", rox: { key: 'd406a39215b8' } do
    $redis.hset STATUS_DATA_CACHE_KEY, 'last_api_payload', 123
    allow(Time).to receive(:now).and_return(now = Time.now)
    expect(subject.compute).to include(lastApiPayload: 123, lastTestDeprecation: now.to_ms, lastTestCounters: now.to_ms, lastPurge: now.to_ms)
  end

  describe "events" do
    let(:last_api_payload){ 1.day.ago.to_ms }
    let(:last_test_deprecation){ 2.days.ago.to_ms }
    let(:last_test_counters){ 3.days.ago.to_ms }
    let(:last_purge){ 4.days.ago.to_ms }
    let(:now){ Time.now }

    before :each do
      $redis.hmset STATUS_DATA_CACHE_KEY, 'last_api_payload', last_api_payload, 'last_test_deprecation', last_test_deprecation, 'last_test_counters', last_test_counters, 'last_purge', last_purge
      allow(Time).to receive(:now).and_return(now)
    end

    it "should touch the last api payload time on the api:payload event", rox: { key: '9d1d4f8f598d' } do
      subject.fire 'api:payload', double
      expect_dates lastApiPayload: now.to_ms
    end

    it "should touch the last test deprecation date on the test:deprecated event", rox: { key: '85811805ed31' } do
      subject.fire 'test:deprecated', double
      expect_dates lastTestDeprecation: now.to_ms
    end

    it "should touch the last test deprecation date on the test:undeprecated event", rox: { key: 'd342219b1503' } do
      subject.fire 'test:undeprecated', double
      expect_dates lastTestDeprecation: now.to_ms
    end

    it "should touch the last test counters date on the test:counters event", rox: { key: '92818bf733e5' } do
      subject.fire 'test:counters'
      expect_dates lastTestCounters: now.to_ms
    end

    keys = %w(b2d41c805d17 46929ecafd3c a8c2fdad3669 70082515e647)
    %w(tags testPayloads testRuns tickets).each do |e|
      it "should touch the last purge date on the purged:#{e} event", rox: { key: keys.shift } do
        subject.fire "purged:#{e}"
        expect_dates lastPurge: now.to_ms
      end
    end

    def expect_dates options = {}
      expect(subject.compute).to include({
        lastApiPayload: last_api_payload,
        lastTestDeprecation: last_test_deprecation,
        lastTestCounters: last_test_counters,
        lastPurge: last_purge
      }.merge(options))
    end
  end
end

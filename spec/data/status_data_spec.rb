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

describe StatusData do
  subject{ described_class }
  STATUS_DATA_CACHE_KEY = 'cache:status'

  it "should return cached dates", rox: { key: 'ea29408c00a8' } do
    t1, t2, t3 = to_timestamp(1.day.ago), to_timestamp(2.days.ago), to_timestamp(3.days.ago)
    $redis.hmset STATUS_DATA_CACHE_KEY, 'last_api_payload', t1, 'last_test_deprecation', t2, 'last_test_counters', t3
    expect(subject.compute).to include(lastApiPayload: t1, lastTestDeprecation: t2, lastTestCounters: t3)
  end

  it "should set missing dates to now", rox: { key: 'd406a39215b8' } do
    $redis.hset STATUS_DATA_CACHE_KEY, 'last_api_payload', 123
    Time.stub now: now = Time.now
    expect(subject.compute).to include(lastApiPayload: 123, lastTestDeprecation: to_timestamp(now), lastTestCounters: to_timestamp(now))
  end

  describe "events" do
    let(:last_api_payload){ to_timestamp 1.day.ago }
    let(:last_test_deprecation){ to_timestamp 2.days.ago }
    let(:last_test_counters){ to_timestamp 3.days.ago }
    let(:now){ Time.now }

    before :each do
      $redis.hmset STATUS_DATA_CACHE_KEY, 'last_api_payload', last_api_payload, 'last_test_deprecation', last_test_deprecation, 'last_test_counters', last_test_counters
      Time.stub now: now
    end

    it "should touch the last api payload time on the api:payload event", rox: { key: '9d1d4f8f598d' } do
      subject.fire 'api:payload', double
      expect(subject.compute).to include(lastApiPayload: to_timestamp(now), lastTestDeprecation: last_test_deprecation, lastTestCounters: last_test_counters)
    end

    it "should touch the last test deprecation date on the test:deprecated event", rox: { key: '85811805ed31' } do
      subject.fire 'test:deprecated', double
      expect(subject.compute).to include(lastApiPayload: last_api_payload, lastTestDeprecation: to_timestamp(now), lastTestCounters: last_test_counters)
    end

    it "should touch the last test deprecation date on the test:undeprecated event", rox: { key: 'd342219b1503' } do
      subject.fire 'test:undeprecated', double
      expect(subject.compute).to include(lastApiPayload: last_api_payload, lastTestDeprecation: to_timestamp(now), lastTestCounters: last_test_counters)
    end

    it "should touch the last test counters date on the test:counters event", rox: { key: '92818bf733e5' } do
      subject.fire 'test:counters'
      expect(subject.compute).to include(lastApiPayload: last_api_payload, lastTestDeprecation: last_test_deprecation, lastTestCounters: to_timestamp(now))
    end
  end

  def to_timestamp time
    (time.to_f * 1000).to_i
  end
end

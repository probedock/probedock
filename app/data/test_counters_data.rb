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
class TestCountersData

  def self.compute
    redis_data.inject({}){ |memo,(k,v)| memo[k.to_s.camelize(:lower).to_sym] = v; memo }.merge totalCounters: TestCounter.count
  end

  def self.fingerprint
    data = redis_data
    DataFingerprint.new data.keys.sort.collect{ |k| data[k] }.join('-')
  end

  def self.queue_size
    Resque.redis.llen "queue:#{CountTestsJob.queue}"
  end

  private

  def self.redis_data

    results = $redis.multi do
      queue_size
      recomputing?
      remaining_results
      preparing?
    end

    { jobs: results[0].to_i, recomputing: !!results[1], remaining_results: results[2].to_i, preparing: !!results[3] }
  end

  def self.recomputing?
    $redis.get TestCounter.cache_key(:recomputing)
  end

  def self.preparing?
    $redis.get TestCounter.cache_key(:preparing)
  end

  def self.remaining_results
    $redis.get TestCounter.cache_key(:remaining_results)
  end
end

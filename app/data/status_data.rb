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

class StatusData

  include RoxHook
  on('api:payload'){ touch_last_api_payload }
  on('test:deprecated', 'test:undeprecated'){ touch_last_test_deprecation }
  on('test:counters'){ touch_last_test_counters }

  def self.compute

    t = to_timestamp Time.now
    results = $redis.multi do
      DATES.each{ |d| $redis.hsetnx CACHE_KEY, d, t }
      $redis.hgetall CACHE_KEY
    end

    DATES.inject({}) do |memo,d|
      memo[d.camelize(:lower).to_sym] = results.last[d].to_i
      memo
    end
  end

  private
  
  CACHE_KEY = 'cache:status'
  DATES = %w(last_api_payload last_test_deprecation last_test_counters)

  class << self
    DATES.each do |d|
      define_method "touch_#{d}" do
        Time.now.tap{ |now| $redis.hset CACHE_KEY, d, to_timestamp(now) }
      end
    end
  end

  def self.to_timestamp time
    (time.to_f * 1000).to_i
  end
end

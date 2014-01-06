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
    {
      jobs: queue_size,
      recomputing: TestCounter.recomputing?,
      remainingResults: remaining_results,
      totalCounters: TestCounter.count
    }
  end

  def self.fingerprint
    "#{queue_size}-#{TestCounter.recomputing?}-#{remaining_results}"
  end

  private

  def self.queue_size
    Resque.size('metrics:test_counters')
  end

  def self.remaining_results
    $redis.get('metrics:test_counters:remaining_results').to_i
  end
end

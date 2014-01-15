# Copyright (c) 2012-2014 Lotaris SA
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
class CurrentTestMetricsData

  include RoxHook
  on 'test:counters' do
    JsonCache.clear :current_test_metrics_data
  end

  def self.compute
    JsonCache.new(:current_test_metrics_data){ compute_data.deep_stringify_keys! }
  end

  private

  def self.compute_data

    tz = TestCounter::DEFAULT_TIMEZONE
    now = Time.now.utc
    today = Time.use_zone(tz){ Time.zone.local now.year, now.month, now.day }.utc
    last_week = today - 7.days
    last_month = today - 30.days

    rel = TestCounter
    rel = rel.select 'timestamp, user_id, written_counter, run_counter, deprecated_counter'
    rel = rel.where timezone: tz
    rel = rel.where 'timestamp >= ?', last_month
    rel = rel.where mask: TestCounter.mask_for(:user)
    rel = rel.order 'timestamp ASC'
    rel = rel.includes :user
    counters = rel.to_a

    bounds = { today: today, week: last_week, month: last_month }
    [ :today, :week, :month ].inject({}) do |memo,k|
      matching = counters.select{ |c| c.timestamp >= bounds[k] }
      memo[k] = {
        written: counter_metric(:written_counter, matching),
        deprecated: counter_metric(:deprecated_counter, matching),
        run: counter_metric(:run_counter, matching)
      }
      memo
    end
  end

  def self.counter_metric counter_column, counters
    { total: counters.inject(0){ |memo,c| memo + c.send(counter_column) } }.tap do |h|
      by_user = metrics_by_user(counter_column, counters).select{ |k,v| v >= 1 }
      if by_user.any?
        best_users = by_user.keys.reject{ |u| u.technical? }.sort{ |u1,u2| by_user[u2] <=> by_user[u1] }.first(3)
        h[:most] = best_users.collect{ |u| user_metric u, by_user[u] }
      end
    end
  end

  def self.user_metric user, n
    {
      user: user.to_client_hash,
      total: n
    }
  end

  def self.metrics_by_user counter_column, counters
    counters.inject({}) do |memo,c|
      memo[c.user] = memo[c.user].to_i + c.send(counter_column)
      memo
    end
  end
end

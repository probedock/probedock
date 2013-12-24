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
class TestCounter < ActiveRecord::Base
  DEFAULT_TIMEZONE = 'Bern'
  BASE_ATTRIBUTES = [ :timezone, :user, :category, :project ]
  COUNTER_ATTRIBUTES = [ :written, :run ]
  attr_accessor :quick_validation

  belongs_to :user
  belongs_to :category
  belongs_to :project

  validates :timezone, presence: true
  validates :timestamp, presence: true
  validates :mask, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :unique_token, presence: true, uniqueness: { unless: :quick_validation }
  validates :user_id, presence: { if: Proc.new{ |c| c.mask & MASK_BITS[:user] != 0 } }
  validates :project_id, presence: { if: Proc.new{ |c| c.mask & MASK_BITS[:project] != 0 } }

  def day
    self.class.day timezone, timestamp
  end

  def self.measure options

    raise "Time is missing" unless options[:time]
    raise "Timezone is missing" unless options[:timezone]

    counter_updates = options.select{ |k,v| COUNTER_ATTRIBUTES.include? k }
    raise "No counter updates" if counter_updates.empty?

    attributes = options.select{ |k,v| BASE_ATTRIBUTES.include? k }

    cache = options[:cache] || {}
    timezone_cache = (cache[options[:timezone]] ||= {})
    attributes[:timestamp] = (timezone_cache[options[:time]] ||= utc_day(options[:time], options[:timezone]))

    mask = mask_for_attrs attributes
    token = build_unique_token attributes, mask
    unless token_known? token

      begin
        c = TestCounter.new
        attributes.each_pair{ |k,v| c.send "#{k}=", v }
        c.mask = mask
        c.unique_token = token
        c.quick_validation = true
        c.save!
      rescue ActiveRecord::RecordNotUnique
        # ignore
      end

      cache_token token, attributes[:timestamp]
    end

    where(unique_token: token).update_all counter_updates.inject([]){ |memo,(k,v)| memo << "#{k}_counter = #{k}_counter + (#{v.to_i})" }.join(', ')
    true
  end

  def self.mask_for *attrs
    MASK_BITS.inject(0){ |memo,(k,v)| attrs.include?(k) ? memo | v : memo }
  end

  def self.recompute! timezones = ROXCenter::Application.metrics_timezones
    return false if $redis.getset cache_key(:recomputing), true

    delete_all
    clean_token_cache true

    TestDeprecation.select('id, deprecated, test_info_id, created_at').to_a.each do |deprecation|
      CountDeprecationJob.enqueue_deprecation deprecation, timezones: timezones
    end

    start_from = TestRun.order('ended_at ASC').limit(1).first.try(:ended_at)

    if !start_from
      TestCounter.clear_computing
      return true
    end

    now = Time.now
    while start_from < now

      bound = start_from + 1.day
      bound = now if bound > now

      runs = TestRun.select('id, results_count').where('ended_at >= ? AND ended_at < ?', start_from, bound).order('ended_at ASC').to_a
      start_from = bound

      next if runs.empty?

      CountTestsJob.enqueue_runs runs, max_time: now.to_f, timezones: timezones
    end

    true
  end

  def self.recomputing?
    !!$redis.get(cache_key(:recomputing))
  end

  def self.clear_computing
    $redis.del cache_key(:recomputing), cache_key(:remaining_results)
  end

  def self.cache_token token, timestamp
    $redis.zadd cache_key(:tokens), timestamp.to_f, token
  end

  def self.token_known? token
    !!$redis.zscore(cache_key(:tokens), token)
  end

  def self.clean_token_cache all = false
    if all
      $redis.del cache_key(:tokens)
    else
      $redis.zremrangebyscore cache_key(:tokens), 0, 1.day.ago.utc.to_f
    end
  end

  def self.remaining_results
    $redis.get(cache_key(:remaining_results)).to_i
  end

  def self.update_remaining_results by
    if by
      $redis.incrby cache_key(:remaining_results), by
    else
      $redis.del cache_key(:remaining_results)
    end
  end

  private

  def self.utc_day time, timezone_name
    Time.use_zone timezone_name do
      local_time = Time.zone.at time.to_time.utc
      Time.zone.local(local_time.year, local_time.month, local_time.day).utc
    end
  end

  def self.cache_key name
    "metrics:test_counters:#{name}"
  end

  def self.build_unique_token attributes, mask
    "#{attributes[:timezone]}:#{day(attributes[:timezone], attributes[:timestamp])}:#{mask}:#{data_token(attributes, mask)}"
  end

  def self.mask_for_attrs attributes
    MASK_BITS.inject(0){ |memo,(k,v)| attributes.key?(k) ? memo | v : memo }
  end

  def self.day timezone, timestamp
    Time.use_zone(timezone){ Time.zone.at(timestamp.to_time).strftime("%Y-%m-%d") }
  end

  def self.data_token attributes, mask
    MASK_BITS.inject([]){ |memo,(k,v)| mask & v != 0 ? memo << (attributes[k].try(:metric_key) || '$') : memo }.join '-'
  end

  MASK_BITS = {
    user: 0,
    category: 1,
    project: 2
  }.inject({}){ |memo,(k,v)| memo[k] = 1 << v; memo }
end

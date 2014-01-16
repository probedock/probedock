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
class ReportCache

  def self.clear id = nil
    safe 'clear cache' do
      if id
        $redis.lrem manifest_key, 0, id.to_s
        Rails.cache.delete report_key(id)
        [ id ]
      else
        $redis.multi do
          $redis.lrange manifest_key, 0, -1
          $redis.del manifest_key
          Rails.cache.delete_matched /^report-/
        end[0]
      end
    end
  end

  def initialize options = {}, &block
    @options, @block = options, block
    @maximum = @options[:max] || 10
  end

  def get id, options = {}
    safe 'load or save cache' do

      # If the force option is set, do not try the cache, always load new data.
      cached = options[:cache] == :force ? nil : load_from_cache(id)

      if enabled? and options[:cache] == :job
        return cached if cached
        cache_in_job id  
        return nil
      end

      # If the cache option is false and the object is not cached, return nil, do not load or cache anything.
      # Allows to check whether a value is in the cache without side effects.
      return nil if !cached && options[:cache] == false

      save_to_cache(id, cached || load_from_scratch(id), !cached, options)
    end
  end

  def enabled?
    maximum >= 1
  end

  private

  def maximum
    @maximum.respond_to?(:call) ? @maximum.call : @maximum
  end

  def cache_in_job id
    unless $redis.get job_key(id)
      $redis.multi do
        $redis.set job_key(id), Time.now.to_f.to_s
        $redis.expire job_key(id), 1.minute.to_i
      end
      Resque.enqueue CacheReportJob, id
    end
  end

  def load_from_scratch id
    raw = @block.call id
    if @options[:type] == :json
      MultiJson.dump raw, mode: :strict
    else
      raw
    end
  end

  def load_from_cache id
    contents = Rails.cache.read report_key(id)
    contents && @options[:compress] ? ActiveSupport::Gzip.decompress(contents) : contents
  end

  def save_to_cache id, contents, new = true, options = {}

    # This is a quick-and-dirty LRU cache.
    # We store the list of report IDs in a Redis list,
    # and we store each cached object in the Rails cache store.
    # See #report_key and #manifest_key for the actual key formats.

    # The list of IDs is kept ordered with the most recently used object first.
    # Every time we add an object to the cache, we trim the list to the maximum
    # number of elements and then delete the cache for the objects with the
    # removed IDs.

    # If warming up and the object is already cached, do nothing.
    warmup = options[:cache] == :warmup
    return contents if warmup and !new

    max = maximum
    cache_contents = @options[:compress] ? ActiveSupport::Gzip.compress(contents) : contents

    data = $redis.multi do

      $redis.lrange manifest_key, 0, -1 # Get the list of object IDs.

      if max >= 1
        $redis.lrem manifest_key, 0, id.to_s # Remove the current ID if it's already in the list.
        Rails.cache.write report_key(id), cache_contents if new # Cache the object if it's new data.
        $redis.lpush manifest_key, id.to_s # Add its ID to the list.
        $redis.ltrim manifest_key, 0, max - 1 # Trim the list to remove least recently used elements.
      end

      $redis.del job_key(id)
    end

    if max >= 1

      # Here we determine the number of old elements to remove.
      # data[0] = list before we did anything (result of lrange operation)
      # data[1] = 1 if the cached object was new, 0 otherwise (number of elements removed by lrem operation)
      n = data[0].length - data[1] + 1 - max

      # data[0].length - data[1] + 1 gives us the size of the list after we cached the object.
      # If that's greater than the maximum, we take the IDs from the end of the list and we delete those cached objects.
      $redis.multi{ expire_objects data[0][-n, n] } if n >= 1
    elsif data[0].present?

      # Delete everything if the cache size is set to zero.
      $redis.multi do
        expire_objects data[0]
        $redis.del manifest_key
      end
    end

    if warmup
      Rails.logger.info "Warmed up report cache for id #{id}"
    elsif new
      Rails.logger.debug "Generated report cache for id #{id} at #{Time.now}"
    else
      Rails.logger.debug "Bumped report cache for id #{id} at #{Time.now}"
    end

    contents
  end

  def expire_objects ids

    Rails.logger.info "Expiring #{ids.length} elements from report cache"

    ids.each do |id|
      Rails.cache.delete report_key(id)
      $redis.lrem manifest_key, 0, id.to_s
    end
  end

  def self.safe operation
    result = nil
    begin
      result = yield if block_given?
    rescue StandardError => e
      Rails.logger.warn "Report cache: could not #{operation}\n#{$redis.inspect}\n#{e}\n#{e.backtrace.join "\n"}"
      result = false
    end
    result
  end

  def safe operation, &block
    self.class.safe operation, &block
  end

  def job_key id
    "cache:reports:#{id}"
  end

  def self.report_key id
    "report-#{id}"
  end

  def report_key id
    self.class.report_key id
  end

  def self.manifest_key
    'cache:reports'
  end

  def manifest_key
    self.class.manifest_key
  end
end

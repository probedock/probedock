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
require 'digest/sha2'

class JsonCache
  KEYS = [ :serialized, :updated_at, :etag ]

  class CachedObject
    attr_accessor :etag, :updated_at

    def initialize options = {}

      raise 'Either contents or serialized contents must be present' if !options.key?(:contents) and !options.key?(:serialized)
      @contents, @serialized = options[:contents], options[:serialized]

      if options[:etag]
        @updated_at = Time.at options[:updated_at].to_i
        @etag = options[:etag] == true ? compute_etag(to_json, @updated_at) : options[:etag]
      end
    end

    def contents
      @contents ||= (@serialized.nil? ? nil : MultiJson.load(@serialized, mode: :strict))
    end

    def to_json options = {}
      @serialized ||= MultiJson.dump(@contents, mode: :strict)
    end

    def to_h
      { serialized: to_json, etag: @etag, updated_at: @updated_at.try(:to_i) }
    end

    private

    def compute_etag contents, updated_at
      Digest::SHA2.hexdigest "#{updated_at.to_i} #{contents}"
    end
  end

  def self.keys
    result = safe 'get keys' do
      $redis.keys('cache:json:*').collect{ |k| k.sub(/\Acache:json:/, '') }
    end
    result || []
  end

  def self.clear *args
    args = keys if args.blank?
    safe 'clear cache' do
      $redis.multi{ args.each{ |k| $redis.del complete_key(k) } }
    end
    args
  end

  def self.get *caches

    raws = $redis.pipelined{ caches.each{ |c| c.send(:raw_from_cache) } }

    result = nil
    $redis.multi{ result = caches.collect.with_index{ |c,i| c.get raw: raws[i], multi: true } }
    result
  end

  def initialize key, options = {}, &block
    @key, @options, @block = key, options, block
  end

  def get options = {}
    safe 'load cache' do
      load_from_cache(options) or save_to_cache(load_from_scratch, options)
    end
  end

  def contents
    (cached = get) ? cached.contents : false
  end

  def to_json options = {}
    get.to_json options
  end

  def clear
    safe('clear cache'){ $redis.del complete_key(@key) }
    self
  end

  private

  def complete_key key
    self.class.complete_key key
  end

  def load_from_scratch
    options = { contents: @block.call }
    options.merge! etag: true, updated_at: Time.now if @options[:etag] != false
    CachedObject.new options
  end

  def load_from_cache options = {}

    raw = options.key?(:raw) ? options[:raw] : raw_from_cache
    return nil if raw.nil? or raw.blank?

    if @options[:etag] != false
      CachedObject.new raw.symbolize_keys.select{ |k,v| KEYS.include?(k) }
    else
      CachedObject.new serialized: raw
    end
  end

  def raw_from_cache
    if @options[:etag] != false
      $redis.hgetall complete_key(@key)
    else
      $redis.get complete_key(@key)
    end
  end

  def save_to_cache cached, options = {}
    options[:multi] ? save(cached) : $redis.multi{ save(cached) }
    cached
  end

  def save cached
    key = complete_key @key

    if @options[:etag] != false
      $redis.hmset *cached.to_h.to_a.flatten.unshift(key)
    else
      $redis.set key, cached.to_json
    end

    $redis.expire key, @options[:expire].to_i if @options[:expire]
  end

  def safe operation, &block
    self.class.safe operation, @key, &block
  end

  def self.safe operation, key = nil
    result = nil
    begin
      result = yield if block_given?
    rescue StandardError => e
      key_notice = key ? " with key '#{complete_key(key)}'" : ""
      Rails.logger.warn "JSON cache#{key_notice}: could not #{operation}\n#{$redis}\n#{e}\n#{e.backtrace.join "\n"}"
      result = false
    end
    result
  end

  def self.complete_key key
    "cache:json:#{key}"
  end
end

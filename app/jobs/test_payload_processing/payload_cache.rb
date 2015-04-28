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
module TestPayloadProcessing
  class Cache
    attr_reader :test_keys, :categories, :tags, :tickets

    def initialize project

      @project = project
      @organization = project.organization

      @test_keys = {}
      @categories = {}
      @tags = {}
      @tickets = {}
    end

    def prefill results

      time = Benchmark.realtime do
        cache_test_keys results
        cache_organization_records results, Category, 'c'
        cache_organization_records results, Tag, 'g'
        cache_organization_records results, Ticket, 't'
      end

      Rails.logger.info "Cached data for #{results.length} results in #{(time * 1000).round 1}ms"
    end

    def test_key key
      @test_keys[key]
    end

    def category name
      @categories[name]
    end

    def tag name
      @tags[name]
    end

    def ticket name
      @tickets[name]
    end

    private

    def cache_test_keys results

      new_keys = results.inject([]){ |memo,result| memo << result['k'] if result.key? 'k'; memo }.reject{ |k| @test_keys.key? k }

      if new_keys.present?
        @project.test_keys.where(key: new_keys).update_all tracked: true
        existing_keys = @project.test_keys.where(key: new_keys).to_a.inject({}){ |memo,test_key| memo[test_key.key] = test_key; memo }

        new_keys.each do |key|
          @test_keys[key] = existing_keys[key] || TestKey.new(key: key, free: false, project_id: @project.id).tap(&:save_quickly!)
        end
      end
    end

    def cache_organization_records results, model, payload_property

      # convert model name to cache type
      # e.g. Tag => :tags
      type = model.name.underscore.pluralize.to_sym
      cache = send type

      # collect all unique result values for the payload property
      # e.g. for tags [{ "g": ["unit", "integration"] }, { "g": ["unit","api"] }] => ["unit", "integration", "api"]
      names = results.inject(Set.new){ |memo,result| result[payload_property].present? ? memo | [*result[payload_property]] : memo }.to_a

      # ignore records that have already been cached
      names.delete_if{ |name| cache.key? name }

      # do nothing if there are no new records
      return if names.blank?

      # fetch the new records that already exist in the database
      # and build a hash of those records by name
      existing_records = model.where(organization: @organization).where('name IN (?)', names).to_a.inject({}){ |memo,record| memo[record.name] = record; memo }

      # add the new records to the cache
      names.each do |name|
        # create new active record objects for the records that are not yet persisted
        cache[name] = existing_records[name] || model.new.tap{ |t| t.name = name; t.organization = @organization; t.quick_validation = true; t.save! }
      end
    end
  end
end

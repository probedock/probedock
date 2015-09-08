# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
module TestPayloadProcessing
  class PayloadCache
    attr_reader :test_data, :test_results, :tests, :test_keys, :categories, :tags, :tickets

    def initialize project_version

      @project_version = project_version
      @project = project_version.project
      @organization = @project.organization
      @test_data = []
      @test_results = []

      @tests = {}
      @test_keys = {}
      @new_test_keys = []
      @categories = {}
      @tags = {}
      @tickets = {}
    end

    def prefill results

      time = Benchmark.realtime do
        cache_test_keys results
        cache_tests results
        cache_organization_records results, Category, 'c'
        cache_organization_records results, Tag, 'g'
        cache_organization_records results, Ticket, 't'
      end

      Rails.logger.info "Cached data for #{results.length} results in #{(time * 1000).round 1}ms"
    end

    def register_result result
      @test_results << result

      has_key = result.key.present?

      existing_data = nil
      existing_data_by_key = @test_data.find{ |d| has_key && d[:key] == result.key }
      existing_data_by_name = @test_data.find{ |d| d[:names].include? result.name }
      existing_data_by_test = @test_data.find{ |d| d[:test] && d[:test] == result.key.try(:test) }

      if existing_data_by_key
        existing_data = existing_data_by_key
        existing_data[:names] << result.name unless existing_data[:names].include? result.name
      end

      if existing_data_by_test
        if existing_data && existing_data_by_test != existing_data
          existing_data[:names] << result.name unless existing_data[:names].include? result.name
          existing_data[:test] = existing_data_by_test[:test] if !existing_data[:test]
          @test_data.delete existing_data_by_test
        elsif !existing_data
          existing_data = existing_data_by_test
          existing_data[:names] << result.name unless existing_data[:names].include? result.name
          existing_data[:key] = result.key if has_key
          existing_data[:test] = result.key.test if has_key && result.key.test && !existing_data[:test]
        end
      end

      if existing_data_by_name
        if existing_data && existing_data_by_name != existing_data
          existing_data[:test] = existing_data_by_name[:test] if !existing_data[:test]
          @test_data.delete existing_data_by_name
        elsif !existing_data
          existing_data = existing_data_by_name
          existing_data[:key] = result.key if has_key
          existing_data[:test] = result.key.test if has_key && result.key.test && !existing_data[:test]
        end
      end

      unless existing_data
        @test_data << {
          key: result.key,
          test: result.key.try(:test) || test(result.name),
          names: [ result.name ]
        }
      end
    end

    def test name
      @tests[name]
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

    def cache_tests results
      new_names = results.inject([]){ |memo,result| memo << result['n'] if result.key?('n') && (!result.key?('k') || @new_test_keys.include?(result['k'])); memo }.reject{ |n| @tests.key? n }

      if new_names.present?

        matching_descriptions = @project_version.test_descriptions.where(name: new_names).includes(:test).to_a
        matching_descriptions.each do |description|
          existing_test = @tests[description.name]
          if !existing_test
            @tests[description.name] = description.test
          elsif !existing_test.key_id && description.test.key_id
            @tests[description.name] = description.test
          end
        end

        remaining_new_names = new_names.reject{ |name| matching_descriptions.any?{ |desc| desc.name == name } }

        if remaining_new_names.present?
          matching_tests = @project.tests.where(name: remaining_new_names).to_a
          matching_tests.each do |test|
            existing_test = @tests[test.name]
            if !existing_test
              @tests[test.name] = test
            elsif !existing_test.key_id && test.key_id
              @tests[test.name] = test
            end
          end
        end
      end
    end

    def cache_test_keys results
      new_keys = results.collect{ |r| r['k'] }.compact.uniq.reject{ |k| @test_keys.key? k }

      if new_keys.present?
        existing_keys = @project.test_keys.where(key: new_keys).includes(:test).to_a.inject({}){ |memo,test_key| memo[test_key.key] = test_key; memo }

        new_keys.each do |key|
          @test_keys[key] = existing_keys[key] || TestKey.new(key: key, free: false, project_id: @project.id).tap(&:save_quickly!)
        end
      end

      @new_test_keys = @test_keys.keys.reject{ |key| @test_keys[key].test }
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

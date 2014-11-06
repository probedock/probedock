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
require 'benchmark'

module TestPayloadProcessing

  class ProcessPayload
    attr_reader :test_payload, :processed_results, :cache

    def initialize test_payload

      raise "Test payload must be in :processing state" unless test_payload.processing?

      @test_payload = test_payload
      data = test_payload.contents
      Rails.logger.info "Starting to process payload received at #{@test_payload.received_at}"

      time = Benchmark.realtime do

        TestPayload.transaction do

          project_version = ProjectVersion.joins(:project).where('projects.api_id = ? AND project_versions.name = ?', data['p'], data['v']).includes(:project).first
          project_version ||= ProjectVersion.new(project_id: Project.where(api_id: data['p']).first!.id, name: data['v']).tap(&:save_quickly!)
          @test_payload.project_version = project_version

          @test_payload.results_count = data['t'].length
          @test_payload.duration = 0

          data['t'].each do |result|

            @test_payload.duration += result['d']

            passed, active = result.fetch('p', true), result.fetch('v', true)
            @test_payload.passed_results_count += 1 if passed
            @test_payload.inactive_results_count += 1 unless active
            @test_payload.inactive_passed_results_count += 1 if passed && !active
          end

          @test_payload.duration = data['d'] if data.key? 'd'

          @cache = build_cache

          @processed_results = Array.new data['t'].length

          i = 0
          data['t'].each_slice 100 do |results|

            fill_cache results
            results.each do |result|
              @processed_results[i] = ProcessResult.new(result, @test_payload, @cache)
              i += 1
            end
          end

          @test_payload.save!

          @test_payload.runner.update_attribute :last_test_payload_id, @test_payload.id

          # Mark test keys as used.
          free_keys = @cache[:test_keys].values.select &:free?
          TestKey.where(id: free_keys.collect(&:id)).update_all free: false if free_keys.any?
        end
      end

      duration = (time * 1000).round 1
      number_of_test_results = data['t'].length

      test_payload.finish_processing!
      Rails.logger.info "Processed API test payload with #{number_of_test_results} test results in #{duration}ms"

      #Rails.application.events.fire 'api:payload', self
    end

    private

    def build_cache
      {
        test_keys: {},
        test_descriptions: [],
        custom_values: [],
        categories: {},
        tags: {},
        tickets: {}
      }
    end

    def fill_cache results

      time = Benchmark.realtime do
        cache_tests results
        cache_custom_values results
        cache_records results, Category, 'c'
        cache_records results, Tag, 'g'
        cache_records results, Ticket, 't'
      end

      Rails.logger.info "Cached data for #{results.length} results in #{(time * 1000).round 1}ms"
    end

    def cache_tests results

      new_keys = results.inject([]){ |memo,result| memo << result['k'] if result['k']; memo }.reject{ |k| @cache[:test_keys].key? k }
      existing_keys = nil

      if new_keys.present?
        existing_keys = @test_result.project_version.project.test_keys.where(key: new_keys).includes([ :user, :project, :test ]).to_a.inject({}){ |memo,test_key| memo[test_key.key] = test_key; memo }

        new_keys.each do |key|
          @cache[:test_keys][key] = existing_keys[key] || TestKey.new(key: key, free: false, project_id: @test_result.project_version.project.id).tap(&:save_quickly!)
        end
      end

      if existing_keys.present?
        @cache[:test_descriptions] |= TestDescription.joins(:test).where(project_version_id: @test_payload.project_version_id, project_tests: { key_id: existing_keys.collect(&:id) }).includes(test: :key).to_a
      end

      test_names = results.inject([]){ |memo,result| memo << result['n'] unless result['k']; memo }
      test_names.reject!{ |name| @cache[:test_descriptions].any?{ |d| d.name == name } }

      if test_names.present?
        @cache[:test_descriptions] |= TestDescription.joins(:project_version).where(project_versions: { project_id: @test_payload.project_version.project_id }, name: test_names).includes(test: :key).to_a
      end
    end

    def cache_custom_values results

      names = results.inject(Set.new){ |memo,result| result['a'].present? ? memo | result['a'].keys : memo }.to_a
      return if names.blank?

      @cache[:custom_values] = TestValue.select('id, name, test_description_id').where(name: names, test_description_id: @cache[:test_descriptions].collect(&:id)).to_a
    end

    def cache_records results, model, payload_property

      # convert model name to cache type
      # e.g. Tag => :tags
      type = model.name.underscore.pluralize.to_sym

      # collect all unique result values for the payload property
      # e.g. for tags [{ "g": ["unit", "integration"] }, { "g": ["unit","api"] }] => ["unit", "integration", "api"]
      names = results.inject(Set.new){ |memo,result| result[payload_property].present? ? memo | [*result[payload_property]] : memo }.to_a

      # ignore records that have already been cached
      names.delete_if{ |name| @cache[type].key? name }

      # do nothing if there are no new records
      return if names.blank?

      # fetch the new records that already exist in the database
      # and build a hash of those records by name
      existing_records = model.where('name IN (?)', names).to_a.inject({}){ |memo,record| memo[record.name] = record; memo }

      # add the new records to the cache
      names.each do |name|
        # create new active record objects for the records that are not yet persisted
        @cache[type][name] = existing_records[name] || model.new.tap{ |t| t.name = name; t.quick_validation = true; t.save! }
      end
    end
  end
end

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
require 'benchmark'

module TestPayloadProcessing
  class ProcessPayload
    attr_reader :test_payload, :cache

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

          organization = project_version.project.organization

          @cache = build_cache

          @test_payload.results_count = data['r'].length
          @test_payload.duration = 0

          @test_payload.duration = data.key?('d') ? data['d'] : data['r'].inject(0){ |memo,r| memo + r['d'] }
          @test_payload.passed_results_count = data['r'].count{ |r| r.fetch 'p', true }
          @test_payload.inactive_results_count = data['r'].count{ |r| !r.fetch('p', true) }
          @test_payload.inactive_passed_results_count = data['r'].count{ |r| r.fetch('p', true) && !r.fetch('v', true) }

          data['r'].each_slice 100 do |results|
            fill_cache results, organization
            results.each do |result|
              test_result = ProcessResult.new(result, @test_payload, @cache).test_result
              ProcessTest.new test_result
            end
          end

          @test_payload.finish_processing!

          # Mark test keys as used.
          free_keys = @cache[:test_keys].values.select &:free?
          TestKey.where(id: free_keys.collect(&:id)).update_all free: false if free_keys.any?

          TestReport.new(organization: organization, runner: @test_payload.runner, test_payloads: [ @test_payload ]).save_quickly!
        end
      end

      duration = (time * 1000).round 1
      number_of_test_results = data['r'].length

      Rails.logger.info "Saved #{number_of_test_results} test payload results in #{duration}ms"
    end

    private

    def build_cache
      {
        test_keys: {},
        categories: {},
        tags: {},
        tickets: {}
      }
    end

    def fill_cache results, organization

      time = Benchmark.realtime do
        cache_test_keys results
        cache_organization_records results, organization, Category, 'c'
        cache_organization_records results, organization, Tag, 'g'
        cache_organization_records results, organization, Ticket, 't'
      end

      Rails.logger.info "Cached data for #{results.length} results in #{(time * 1000).round 1}ms"
    end

    def cache_test_keys results

      new_keys = results.inject([]){ |memo,result| memo << result['k'] if result.key? 'k'; memo }.reject{ |k| @cache[:test_keys].key? k }

      if new_keys.present?
        @test_payload.project_version.project.test_keys.where(key: new_keys).update_all tracked: true
        existing_keys = @test_payload.project_version.project.test_keys.where(key: new_keys).to_a.inject({}){ |memo,test_key| memo[test_key.key] = test_key; memo }

        new_keys.each do |key|
          @cache[:test_keys][key] = existing_keys[key] || TestKey.new(key: key, free: false, project_id: @test_payload.project_version.project_id).tap(&:save_quickly!)
        end
      end
    end

    def cache_organization_records results, organization, model, payload_property

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
      existing_records = model.where(organization: organization).where('name IN (?)', names).to_a.inject({}){ |memo,record| memo[record.name] = record; memo }

      # add the new records to the cache
      names.each do |name|
        # create new active record objects for the records that are not yet persisted
        @cache[type][name] = existing_records[name] || model.new.tap{ |t| t.name = name; t.organization = organization; t.quick_validation = true; t.save! }
      end
    end
  end
end

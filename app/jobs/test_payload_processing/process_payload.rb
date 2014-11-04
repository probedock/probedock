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
    attr_reader :test_payload, :cache

    def initialize test_payload

      raise "Test payload must be in :processing state" unless test_payload.processing?

      @test_payload = test_payload
      data = test_payload.contents
      Rails.logger.info "Starting to process payload received at #{@test_payload.received_at}"

      time = Benchmark.realtime do

        data = HashWithIndifferentAccess.new data

        TestPayload.transaction do

          @cache = self.class.build_cache data
          #@processed_test_run = ProcessTestRun.new data, @test_payload, @cache

          # Mark test keys as used.
          #free_keys = @cache[:keys].select &:free?
          #TestKey.where(id: free_keys.collect(&:id)).update_all free: false if free_keys.any?

          #test_payload.test_run = @processed_test_run.test_run
          test_payload.finish_processing!
        end
      end

      duration = (time * 1000).round 1
      number_of_test_results = data[:t].length
      Rails.logger.info "Processed API test payload with #{number_of_test_results} test results in #{duration}ms"

      #Rails.application.events.fire 'api:payload', self
    end

    private

    def self.build_cache data
      Hash.new.tap do |cache|

        time = Benchmark.realtime do

          project = Project.where(api_id: data[:p]).first!
          cache[:project] = project

          cache[:project_version] = project.versions.where(name: data[:v]).first || ProjectVersion.new.tap{ |v| v.project_id = project.id; v.name = data[:v]; v.quick_validation = true; v.save! }

          cache[:keys] = project.test_keys.where(key: data[:t].select{ |t| t[:k] }.collect{ |t| t[:k] }).includes([ :user, :project, { test_info: [ :deprecation, :tags, :tickets ] } ]).to_a
          cache[:tests] = cache[:keys].collect(&:test_info).compact

          custom_value_names = data[:t].collect{ |result| result[:a].try :keys }.compact.flatten.uniq
          cache[:custom_values] = TestValue.select('id, name, test_info_id').where(name: custom_value_names, test_info_id: cache[:tests].collect(&:id))

          cache[:categories] = build_categories_cache data
          cache[:tags] = build_tags_cache data
          cache[:tickets] = build_tickets_cache data
        end

        Rails.logger.info "Cached payload data in #{(time * 1000).round 1}ms"
      end
    end

    def self.build_categories_cache data
      category_names = data[:t].collect{ |result| result[:c] }.compact.uniq
      Category.where('name IN (?)', category_names).to_a.tap do |categories|
        category_names.reject{ |name| categories.find{ |cat| cat.name == name } }.each do |name|
          categories << Category.new.tap{ |cat| cat.name = name; cat.quick_validation = true; cat.save! }
        end
      end
    end

    def self.build_tags_cache data
      tags = data[:t].collect{ |result| result[:g] }.compact.flatten.uniq
      existing_tags = Tag.where('name IN (?)', tags)
      tags.collect{ |name| existing_tags.find{ |tag| tag.name == name } || Tag.new.tap{ |t| t.name = name; t.quick_validation = true; t.save! } }
    end

    def self.build_tickets_cache data
      tickets = data[:t].collect{ |result| result[:t] }.compact.flatten.uniq
      existing_tickets = Ticket.where('name IN (?)', tickets)
      tickets.collect{ |name| existing_tickets.find{ |ticket| ticket.name == name } || Ticket.new.tap{ |t| t.name = name; t.quick_validation = true; t.save! } }
    end
  end
end

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
module TestPayloadProcessing

  class ProcessResult
    attr_reader :test, :test_result

    def initialize data, test_payload, cache

      category = cache[:categories][data['c']]
      raise "Expected to find category '#{data['c']}' in cache" if data.key?('c') && category.blank?

      test_key = cache[:test_keys][data['k']]
      raise "Expected to find test key '#{data['k']}' in cache" if data.key?('k') && test_key.blank?

      @test_description = if data.key? 'k'
        cache[:test_descriptions].find{ |d| d.test.key.try(:key) == data['k'] }
      else
        cache[:test_descriptions].find{ |d| d.test.name == data['n'] }
      end

      @test = @test_description.try(:test) || ProjectTest.new

      if @test.new_record?
        @test.key = test_key
        @test.project = test_payload.project_version.project

        # TODO: set contributors from key and annotation
      end

      if @test_description.blank?
        @test_description = TestDescription.new test: @test, project_version: test_payload.project_version
      end

      if @test.key.blank?
        @test.key = TestKey.new(project: test_payload.project_version.project, free: false).tap(&:save_quickly!)
      end

      @test.results_count += 1
      @test_description.results_count += 1

      @test_result = build_result data, test, test_payload, cache

      @test_description.name = data['n'].to_s if data['n'].present?
      @test_description.passing = @test_result.passed
      @test_description.active = @test_result.active

      @test_description.category = category if data.key?('c')
      @test_result.category = @test_description.category

      @test_description.last_run_at = @test_result.run_at
      @test_description.last_duration = @test_result.duration
      @test_description.last_runner = test_payload.runner
      @test_description.last_result = @test_result

      @test_description.tags = tags data, cache if data.key?('g')
      @test_description.tickets = tickets data, cache if data.key?('g')

      if data['a'].present?
        data['a'].each_pair do |name,contents|
          value = cache[:custom_values].find{ |v| v.name == name.to_s && v.test_description_id == @test_description.id }
          value ||= TestValue.new(name: name, test_description: @test_description).tap{ |v| v.quick_validation = true }
          value.contents = contents
          @test_description.custom_values << value
        end
      end

      # TODO: only if more recent version
      @test.name = @test_description.name

      @test.save_quickly!
      @test_description.save_quickly!
      @test_result.save_quickly!
    end

    def build_result data, test, payload, cache
      TestResult.new.tap do |result|
        result.new_test = test.new_record?
        result.runner = payload.runner
        result.test = test
        result.test_payload = payload
        result.passed = data.fetch 'p', true
        result.active = data.fetch 'v', true
        result.duration = data['d'].to_i
        result.project_version = payload.project_version
        result.message = data['m'].to_s if data['m'].present?
        result.run_at = payload.run_ended_at
      end
    end

    def tags data, cache
      data['g'].uniq.collect do |name|
        tag = cache[:tags][name]
        raise "Expected to find tag '#{name}' in cache" if tag.blank?
        tag
      end
    end

    def tickets data, cache
      data['t'].uniq.collect do |name|
        ticket = cache[:tickets][name]
        raise "Expected to find ticket '#{name}' in cache" if ticket.blank?
        ticket
      end
    end
  end
end

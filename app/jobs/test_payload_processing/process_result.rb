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

      @test = if data.key? 'k'
        test_key.test_info
      else
        cache[:tests][data['n']]
      end

      @test ||= TestInfo.new

      if @test.new_record?
        @test.key = test_key
        @test.project = test_payload.project_version.project
        # TODO: set contributors from key and annotation
      end

      if @test.key.blank?
        key = TestKey.new(project: @test.project, test_info: @test, free: false).tap(&:save!)
        @test.key = key
      end

      @test.results_count += 1

      test_deprecated = !@test.new_record? && !!@test.deprecated_at

      @test_result = build_result data, test, test_deprecated, test_payload, cache

      @test.name = data['n'].to_s if data['n'].present?
      @test.passing = @test_result.passed
      @test.active = @test_result.active

      @test.category = category if data.key?('c')
      @test_result.category = @test.category

      @test.last_run_at = @test_result.run_at
      @test.last_run_duration = @test_result.duration
      @test.last_runner = test_payload.runner
      @test.last_result = @test_result

      @test.tags = tags data, cache if data.key?('g')
      @test.tickets = tickets data, cache if data.key?('g')

      if data['a'].present?
        data['a'].each_pair do |name,contents|
          value = cache[:custom_values].find{ |v| v.name == name.to_s && v.test_info_id == @test.id }
          value ||= TestValue.new.tap{ |v| v.name = name; v.test_info = @test; v.quick_validation = true }
          value.contents = contents
          @test.custom_values << value
        end
      end

      @test.quick_validation = true

      @test.save!
      @test_result.save!

      @test.quick_validation = false
    end

    def build_result data, test, test_deprecated, payload, cache
      TestResult.new.tap do |result|
        result.new_test = test.new_record?
        result.runner = payload.runner
        result.test_info = test
        result.test_payload = payload
        result.passed = data.fetch 'p', true
        result.active = data.fetch 'v', true
        result.duration = data['d'].to_i
        result.project_version = payload.project_version
        result.message = data['m'].to_s if data['m'].present?
        result.run_at = payload.run_ended_at
        result.deprecated = test_deprecated
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

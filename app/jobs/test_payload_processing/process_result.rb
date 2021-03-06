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
  class ProcessResult
    attr_reader :test_result

    def initialize data, test_payload, cache

      @test_result = TestResult.new
      @test_result.name = data['n']
      @test_result.payload_index = cache.test_results.length

      @test_result.key = test_key data, cache if data.key?('k') && !data['k'].nil?

      @test_result.new_test = false # TODO: make it false by default in the database

      @test_result.test_payload = test_payload
      @test_result.runner = test_payload.runner
      @test_result.project_version = test_payload.project_version

      @test_result.passed = data.fetch 'p', true
      @test_result.active = data.fetch 'v', true
      @test_result.duration = data['d'].to_i
      @test_result.message = data['m'].to_s if data['m'].present?
      @test_result.run_at = test_payload.ended_at

      @test_result.category = category data, cache if data.key?('c') && !data['c'].nil?
      @test_result.tags = tags data, cache if data.key? 'g'
      @test_result.tickets = tickets data, cache if data.key? 't'

      @test_result.custom_values = data['a'] if data.key? 'a'

      # Fix java.class that contains package. This fix avoid old JUnit probes to continue corrupting the test metadata
      if @test_result.custom_values['java.class']
        @test_result.custom_values['java.class'] = @test_result.custom_values['java.class'].gsub(/.*\./, '')
      end

      # TODO: save contributors

      @test_result.payload_properties_set = payload_properties_set data

      @test_result.save_quickly!

      cache.register_result @test_result
    end

    def payload_properties_set data
      {
        key: 'k',
        name: 'n',
        category: 'c',
        tags: 'g',
        tickets: 't',
        custom_values: 'a'
      }.inject([]){ |memo,(property,key)| data.key?(key) ? memo << property : memo }
    end

    def test_key data, cache
      cache.test_key(data['k']).tap do |test_key|
        raise "Expected to find test key '#{data['k']}' in cache" if test_key.blank?
      end
    end

    def category data, cache
      cache.category(data['c']).tap do |category|
        raise "Expected to find category '#{data['c']}' in cache" if data.key?('c') && category.blank?
      end
    end

    def tags data, cache
      data['g'].uniq.collect do |name|
        cache.tag(name).tap do |tag|
          raise "Expected to find tag '#{name}' in cache" if tag.blank?
        end
      end
    end

    def tickets data, cache
      data['t'].uniq.collect do |name|
        cache.ticket(name).tap do |ticket|
          raise "Expected to find ticket '#{name}' in cache" if ticket.blank?
        end
      end
    end
  end
end

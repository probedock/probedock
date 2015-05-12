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
  class ProcessResult
    attr_reader :test, :test_result

    def initialize data, test_payload, cache

      @test_result = TestResult.new
      @test_result.name = data['n']

      @test_result.key = test_key data, cache

      @test_result.test = if @test_result.key_id
        @test_result.key.test
      else
        cache.test @test_result.name
      end

      @test_result.name ||= @test_result.test.try(:name)

      @test_result.new_test = @test_result.test_id.blank?

      @test_result.test_payload = test_payload
      @test_result.runner = test_payload.runner
      @test_result.project_version = test_payload.project_version

      @test_result.passed = data.fetch 'p', true
      @test_result.active = data.fetch 'v', true
      @test_result.duration = data['d'].to_i
      @test_result.message = data['m'].to_s if data['m'].present?
      @test_result.run_at = test_payload.ended_at

      # TODO: support caching
      @test_result.category = category data, cache if data.key? 'c'
      @test_result.tags = tags data, cache if data.key? 'g'
      @test_result.tickets = tickets data, cache if data.key? 't'

      @test_result.custom_values = data['a'] if data.key? 'a'

      # TODO: save contributors

      @test_result.payload_properties_set = payload_properties_set data

      @test_result.save_quickly!
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
        raise "Expected to find test key '#{data['k']}' in cache" if data.key?('k') && test_key.blank?
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

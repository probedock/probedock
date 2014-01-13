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
class ProcessApiPayloadJob

  class ProcessApiTestRun
    attr_reader :test_run, :processed_tests

    def initialize data, runner, time_received, cache

      @test_run = cache[:run] || TestRun.new
      new_record = @test_run.new_record?

      @test_run.runner = runner

      @test_run.uid = data[:u].to_s if data[:u].present?
      @test_run.group = data[:g].to_s if data[:g].present?
      @test_run.ended_at = time_received
      @test_run.duration = data[:d].to_i
      @test_run.results_count ||= 0
      @test_run.passed_results_count ||= 0
      @test_run.inactive_results_count ||= 0
      @test_run.inactive_passed_results_count ||= 0

      # If it's a new record, it must be saved now so test results can be linked to it.
      @test_run.save! if new_record

      @processed_tests = []
      data[:r].each do |results|
        additional_test_data = results.pick :j, :v # enrich tests with project and version
        @processed_tests += results[:t].collect{ |test| ProcessApiTest.new test.merge(additional_test_data), @test_run, cache }
      end

      # Update cached counters.
      @test_run.results_count += @processed_tests.length
      @test_run.passed_results_count += @processed_tests.select{ |j| j.test_result.passed }.length
      @test_run.inactive_results_count += @processed_tests.reject{ |j| j.test_result.active }.length
      @test_run.inactive_passed_results_count += @processed_tests.select{ |j| j.test_result.passed and !j.test_result.active }.length

      # Save counter updates.
      @test_run.save!

      @test_run.runner.update_attribute :last_run_id, @test_run.id

      ROXCenter::Application.events.fire 'api:test_run', self
    end
  end
end

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
require 'resque/plugins/workers/lock'

module ProcessNextTestResultJob
  extend Resque::Plugins::Workers::Lock

  @queue = :api

  def self.perform lock

    test_result_id = $redis.lpop "processing:results:#{lock}"
    test_result = TestResult.includes(:runner, :category, :tags, :tickets, :custom_values, { key: :test, project_version: :project }).find test_result_id

    TestResult.transaction do
      process_test_result test_result
      finish_processing_test_payload test_result.test_payload_id
    end

  end

  def self.finish_processing_test_payload test_payload_id
    payload = TestPayload.select('id, state, results_count, processed_results_count').where(id: test_payload_id).first!
    if payload.processed_results_count == payload.results_count
      Resque.enqueue CompleteTestPayloadProcessingJob, payload.id
    end
  end

  def self.process_test_result test_result

    project = test_result.project_version.project

    key = test_result.key
    test = key.test
    new_test = test.blank?

    if new_test
      test = ProjectTest.new(key: key, project: project, name: test_result.name, results_count: 1).tap(&:save_quickly!)
    end

    description = new_test ? nil : test.descriptions.where(project_version_id: test_result.project_version_id).includes(:custom_values).first
    new_description = description.blank?

    if new_description
      description = TestDescription.new test: test, project_version: test_result.project_version
    end

    # TODO: handle client caching (fill name, tags, etc if not given in payload)
    description.name = test_result.name
    description.passing = test_result.passed
    description.active = test_result.active
    description.last_duration = test_result.duration
    description.last_run_at = test_result.run_at
    description.last_runner = test_result.runner
    description.last_result = test_result
    description.category = test_result.category
    description.tags = test_result.tags
    description.tickets = test_result.tickets

    custom_values = description.custom_values.to_a
    test_result.custom_values.each do |custom_value|

      previous_custom_value = custom_values.find{ |v| v.name == custom_value.name }
      custom_values.delete previous_custom_value if previous_custom_value

      custom_values << custom_value
    end

    description.custom_values = custom_values

    description.results_count += 1
    description.save!

    unless new_test
      # FIXME: change name only if project version is the latest
      test.name = test_result.name
      test.results_count += 1
      test.save!
    end

    TestResult.where(id: test_result.id).update_all processed: true, new_test: new_test, test_id: test.id
    TestPayload.increment_counter :processed_results_count, test_result.test_payload_id
    Project.increment_counter :tests_count, test_result.project_version.project_id if new_test
  end

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers lock
    "#{name}:#{lock}"
  end
end

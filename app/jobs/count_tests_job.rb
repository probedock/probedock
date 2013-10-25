# Copyright (c) 2012-2013 Lotaris SA
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

class CountTestsJob
  @queue = 'metrics:test_counters'

  include RoxHook
  on('api:payload'){ |job| enqueue_results job.processed_test_run.processed_tests.collect(&:test_result), timezones: ROXCenter::Application.metrics_timezones }

  def self.enqueue_runs runs, options = {}
    TestCounter.update_remaining_results runs.inject(0){ |memo,run| memo + run.results_count }
    Resque.enqueue self, options.merge(run_ids: runs.collect(&:id))
  end

  def self.enqueue_results results, options = {}
    Rails.logger.debug "Updating test counters for #{results.length} new test results in background job"
    TestCounter.update_remaining_results results.length
    Resque.enqueue self, options.merge(result_ids: results.collect(&:id))
  end

  def self.perform options = {}
    options = HashWithIndifferentAccess.new options
    max_time = options[:max_time] ? Time.at(options[:max_time]) : nil

    timezones = options[:timezones]
    raise ":timezones option is missing" unless timezones

    results = if options[:result_ids]
      TestResult.includes([ :category, :previous_category, :runner, { test_info: [ :project, :author ] } ]).find(options[:result_ids])
    elsif options[:run_ids]
      TestRun.includes(results: [ :category, :previous_category, :runner, { test_info: [ :project, :author ] } ]).find(options[:run_ids]).inject([]) do |memo,run|
        max_time ? memo + run.results.select{ |r| r.run_at <= max_time } : memo + run.results
      end
    end

    time_cache = {}
    cache = Hash.new{ |h,k| h[k] = k.merge(cache: time_cache, written: 0, run: 0) }
    timezones.each do |timezone|
      results.each do |result|
        new result, timezone, cache
      end
    end

    time_cache = {}
    cache.each_value{ |options| TestCounter.measure options }

    TestCounter.update_remaining_results -results.length

    if !TestCounter.recomputing?
      TestCounter.clean_token_cache
    elsif TestCounter.remaining_results <= 0
      $redis.multi do
        TestCounter.clear_computing
        TestCounter.clean_token_cache
      end
    end

    ROXCenter::Application.events.fire 'test:counters'
  end

  def initialize result, timezone, cache
    
    @cache = cache
    @counter_base = { timezone: timezone, time: result.run_at }

    project = result.test_info.project
    author = result.test_info.author
    runner = result.runner
    category = result.category
    previous_category = result.previous_category

    count :run
    count :run, project: project
    count :run, project: project, category: category
    count :run, project: project, user: runner
    count :run, category: category
    count :run, category: category, user: runner
    count :run, user: runner

    if result.new_test
      count :written
      count :written, project: project
      count :written, project: project, category: category
      count :written, project: project, user: author
      count :written, category: category
      count :written, category: category, user: author
      count :written, user: author
    elsif category != previous_category # FIXME: don't count category changes when deprecated
      count :written, { category: category }, 1
      count :written, { category: category, project: project }, 1
      count :written, { category: category, user: author }, 1
      count :written, { category: previous_category }, -1
      count :written, { category: previous_category, project: project }, -1
      count :written, { category: previous_category, user: author }, -1
    end
  end

  private

  def count type, options = {}, n = 1
    cached = @cache[@counter_base.merge(options)]
    cached[type] += n
  end
end

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
require 'spec_helper'

describe CountTestsJob do
  COUNT_TESTS_JOB_QUEUE = 'metrics:test_counters'

  before :each do
    ResqueSpec.reset!
  end

  it "should go in the #{COUNT_TESTS_JOB_QUEUE} queue", rox: { key: 'c3033e4f9e76' } do
    expect(described_class.queue).to eq(COUNT_TESTS_JOB_QUEUE)
    expect(described_class.instance_variable_get('@queue')).to eq(COUNT_TESTS_JOB_QUEUE)
  end

  describe "events" do
    let(:timezones){ [ 'UTC', 'Bern' ] }
    before(:each){ allow(ROXCenter::Application).to receive(:metrics_timezones).and_return(timezones) }

    it "should enqueue results on the api:payload event", rox: { key: '9b89f251da79' } do
      result_doubles = Array.new(5){ |i| double id: i * 66 }
      expect(described_class).to receive(:enqueue_results).with(result_doubles, timezones: timezones)
      described_class.fire 'api:payload', double(processed_test_run: double(processed_tests: Array.new(5){ |i| double test_result: result_doubles[i] }))
    end
  end

  describe ".enqueue_runs" do
    let(:user){ create :user }
    let(:runs){ Array.new(3){ |i| create :test_run, runner: user, results_count: i + 1 } }

    it "should enqueue a job with the run ids", rox: { key: '4565c3552fc6' } do
      described_class.enqueue_runs runs, foo: 'bar'
      expect(described_class).to have_queued(run_ids: runs.collect(&:id), foo: 'bar')
      expect(described_class).to have_queue_size_of(1)
    end

    it "should update remaining results by the number of results in the runs", rox: { key: '27676b77aed3' } do
      expect(TestCounter).to receive(:update_remaining_results).with(6)
      described_class.enqueue_runs runs, foo: 'bar'
    end
  end

  describe ".enqueue_results" do
    let(:user){ create :user }
    let(:test_keys){ Array.new(3){ |i| create :test_key, user: user } }
    let(:tests){ Array.new(3){ |i| create :test, key: test_keys[i], run_at: i.days.ago, runner: user } }
    let(:results){ tests.collect &:effective_result }

    it "should enqueue a job with the result ids", rox: { key: 'e0aba7c4c98f' } do
      described_class.enqueue_results results, foo: 'bar'
      expect(described_class).to have_queued(result_ids: results.collect(&:id), foo: 'bar')
      expect(described_class).to have_queue_size_of(1)
    end

    it "should update remaining results by the number of results", rox: { key: '632c5a5150cf' } do
      expect(TestCounter).to receive(:update_remaining_results).with(3)
      described_class.enqueue_results results, foo: 'bar'
    end

    it "should log the number of results", rox: { key: '9a6b75bccea9' } do
      expect(Rails.logger).to receive(:debug).with(/updating test counters.*#{results.length}/i)
      described_class.enqueue_results results, foo: 'bar'
    end
  end

  describe ".perform" do
    let(:user){ create :user }
    let(:test_keys){ Array.new(6){ |i| create :test_key, user: user } }
    let(:test_runs){ Array.new(3){ |i| create :test_run, runner: user, ended_at: (i + 1).days.ago, results_count: 2, passed_results_count: 2 } }
    let!(:tests){ Array.new(6){ |i| create :test, key: test_keys[i], test_run: test_runs[((i + 1) / 2.0).ceil - 1], run_at: (((i + 1) / 2.0).ceil).days.ago, runner: user } }
    let(:test_results){ test_runs.inject([]){ |memo,run| memo + run.results } }
    let(:timezones){ [ 'Bern' ] }
    let(:perform_options){ { timezones: timezones } }
    let(:measures){ [] }
    let(:test_counter_stub){ double recomputing?: false, clean_token_cache: nil, update_remaining_results: nil }

    before :each do
      allow(described_class).to receive(:new).and_return(nil)
      stub_const TestCounter.name, test_counter_stub
      allow(test_counter_stub).to receive(:measure) do |options|
        measures << options
      end
    end

    it "should raise an error without the :timezones option", rox: { key: '98b1ef1a0f84' } do
      expect{ described_class.perform run_ids: test_runs.collect(&:id) }.to raise_error(StandardError, ":timezones option is missing")
    end

    it "should instantiate a job for each loaded test results, with the timezone and an empty cache", rox: { key: '9eac8ec7751d' } do

      job_args = []
      allow(described_class).to receive(:new){ |*args| job_args << args }
      described_class.perform perform_options.merge(result_ids: test_results.collect(&:id))

      expect(job_args).to have(6).items
      expect(job_args.collect{ |args| args[0] }).to match_array(test_results)
      expect(job_args.collect{ |args| args[1] }).to match_array(timezones * 6)

      cache = job_args.last[2]
      expect(cache).to eq({})
      job_args.first(5).each{ |args| expect(args[2]).to be(cache) }
    end

    it "should decrease remaining results by the number of results", rox: { key: '8e29da39dd6e' } do
      expect(test_counter_stub).to receive(:update_remaining_results).with(-test_results.length)
      allow(described_class).to receive(:new).and_return(nil)
      described_class.perform perform_options.merge(result_ids: test_results.collect(&:id))
    end

    it "should instantiate a job with the results of each loaded test run, with the timezone and an empty cache", rox: { key: '52e5beac81b7' } do

      job_args = []
      allow(described_class).to receive(:new){ |*args| job_args << args }
      described_class.perform perform_options.merge(run_ids: test_runs.collect(&:id))

      expect(job_args).to have(6).items
      expect(job_args.collect{ |args| args[0] }).to match_array(test_results)
      expect(job_args.collect{ |args| args[1] }).to match_array(timezones * 6)

      cache = job_args.last[2]
      expect(cache).to eq({})
      job_args.first(5).each{ |args| expect(args[2]).to be(cache) }
    end

    it "should decrease remaining results by the number of results in the loaded test runs", rox: { key: 'a9a9cdd3c4f0' } do
      expect(test_counter_stub).to receive(:update_remaining_results).with(-test_results.length)
      allow(described_class).to receive(:new).and_return(nil)
      described_class.perform perform_options.merge(run_ids: test_runs.collect(&:id))
    end

    it "should omit test run results after the :max_time option", rox: { key: 'aa1f0571d104' } do

      now = Time.now
      test_runs.last.update_attribute :ended_at, now
      2.times{ |i| create :test_result, runner: user, test_info: tests[i], run_at: now, test_run: test_runs.last }

      job_args = []
      allow(described_class).to receive(:new){ |*args| job_args << args }

      max_time = now - 1.second
      described_class.perform perform_options.merge(run_ids: test_runs.collect(&:id), max_time: max_time)

      expect(job_args).to have(6).items
      expect(job_args.collect{ |args| args[0] }).to match_array(test_results.select{ |r| r.run_at <= max_time })
      expect(job_args.collect{ |args| args[1] }).to match_array(timezones * 6)

      cache = job_args.last[2]
      expect(cache).to eq({})
      job_args.first(5).each{ |args| expect(args[2]).to be(cache) }
    end

    it "should decrease remaining results by the number of results in the loaded test runs that are before the :max_time option", rox: { key: '24ff101ac0cb' } do

      now = Time.now
      test_runs.last.update_attribute :ended_at, now
      2.times{ |i| create :test_result, runner: user, test_info: tests[i], run_at: now, test_run: test_runs.last }

      max_time = now - 1.second
      expect(test_counter_stub).to receive(:update_remaining_results).with(-test_results.select{ |r| r.run_at <= max_time }.length)

      allow(described_class).to receive(:new).and_return(nil)
      described_class.perform perform_options.merge(run_ids: test_runs.collect(&:id), max_time: max_time)
    end

    it "should pass a counter cache to instantiated jobs", rox: { key: '937c52d98437' } do

      caches = []
      allow(described_class).to receive(:new){ |*args| caches << args[2] }
      described_class.perform perform_options.merge(run_ids: test_runs.collect(&:id))

      today, yesterday = 0.days.ago, 1.day.ago
      caches.first[{ timezone: 'Bern', time: today }][:written] += 3
      caches.first[{ timezone: 'Bern', time: today }][:written] += 2
      caches.first[{ timezone: 'Bern', time: today }][:run] += 6
      caches.first[{ timezone: 'Bern', time: yesterday }][:run] += 42

      expect(caches.first[{ timezone: 'Bern', time: today }][:written]).to eq(5)
      expect(caches.first[{ timezone: 'Bern', time: today }][:run]).to eq(6)
      expect(caches.first[{ timezone: 'Bern', time: yesterday }][:written]).to eq(0)
      expect(caches.first[{ timezone: 'Bern', time: yesterday }][:run]).to eq(42)
    end

    it "should measure counter updates resulting from job instantiation", rox: { key: '84348e75d2cc' } do

      two_days_ago, three_days_ago = 2.days.ago, 3.days.ago
      allow(described_class).to receive(:new) do |result,timezone,cache|
        cache[{ time: two_days_ago, timezone: 'Bern' }][:written] += 1
        cache[{ time: two_days_ago, timezone: 'Bern', project: tests[0].project }][:written] += 2
        cache[{ time: two_days_ago, timezone: 'Bern', user: user }][:written] += 3
        cache[{ time: three_days_ago, timezone: 'Bern', project: tests[1].project, category: nil }][:written] += 4
        cache[{ time: three_days_ago, timezone: 'Bern', user: user }][:written] += 5
        cache[{ time: two_days_ago, timezone: 'Bern' }][:run] += 6
        cache[{ time: three_days_ago, timezone: 'Bern', project: tests[1].project, category: nil }][:run] += 7
        cache[{ time: three_days_ago, timezone: 'Bern', project: tests[1].project }][:run] += 8
        cache[{ time: three_days_ago, timezone: 'Bern' }][:run] += 9
      end
      described_class.perform perform_options.merge(result_ids: test_results.first(1).collect(&:id))

      expect(measures).to have(7).items
      expect(measures).to include(time: two_days_ago, timezone: 'Bern', written: 1, run: 6, cache: {})
      expect(measures).to include(time: two_days_ago, timezone: 'Bern', project: tests[0].project, written: 2, run: 0, cache: {})
      expect(measures).to include(time: two_days_ago, timezone: 'Bern', user: user, written: 3, run: 0, cache: {})
      expect(measures).to include(time: three_days_ago, timezone: 'Bern', project: tests[1].project, category: nil, written: 4, run: 7, cache: {})
      expect(measures).to include(time: three_days_ago, timezone: 'Bern', user: user, written: 5, run: 0, cache: {})
      expect(measures).to include(time: three_days_ago, timezone: 'Bern', project: tests[1].project, written: 0, run: 8, cache: {})
      expect(measures).to include(time: three_days_ago, timezone: 'Bern', written: 0, run: 9, cache: {})

      caches = measures.collect{ |options| options[:cache] }
      expect(caches.last).to eq({})
      caches.first(6).each{ |c| expect(c).to be(caches.last) }
    end

    it "should clean the token cache if not recomputing", rox: { key: '45dc83979e95' } do
      allow(test_counter_stub).to receive(:recomputing?).and_return(false)
      expect(test_counter_stub).to receive(:clean_token_cache)
      described_class.perform perform_options.merge(result_ids: test_results.collect(&:id))
    end

    it "should trigger a test:counters event on the application", rox: { key: '4c74c37fb77b' } do
      expect(ROXCenter::Application.events).to receive(:fire).with('test:counters')
      described_class.perform perform_options.merge(result_ids: test_results.collect(&:id))
    end

    describe "when recomputing" do
      before :each do
        allow(test_counter_stub).to receive(:recomputing?).and_return(true)
        allow(test_counter_stub).to receive(:remaining_results).and_return(42)
        allow(test_counter_stub).to receive(:clear_computing).and_return(nil)
      end

      it "should not clean the token cache", rox: { key: 'c050382c580e' } do
        expect(test_counter_stub).not_to receive(:clean_token_cache)
        expect(test_counter_stub).not_to receive(:clear_computing)
        perform
      end

      it "should clean the token cache and clear computing if there are no more remaining results", rox: { key: '11fd903d18b7' } do
        allow(test_counter_stub).to receive(:remaining_results).and_return(0)
        expect(test_counter_stub).to receive(:clean_token_cache)
        expect(test_counter_stub).to receive(:clear_computing)
        perform
      end

      def perform
        described_class.perform perform_options.merge(result_ids: test_results.collect(&:id))
      end
    end
  end

  describe "processing" do
    let(:run_at){ Time.utc 2012, 01, 01 }
    let(:author){ create :user }
    let(:runner){ create :other_user }
    let(:project){ create :project }
    let(:categories){ Array.new(2){ |i| create :category } }
    let(:test_key){ create :test_key, user: author }
    let(:test){ create :test, key: test_key }
    let(:timezone){ 'Bern' }
    let(:cache){ Hash.new{ |h,k| h[k] = { written: 0, run: 0 } } }

    it "should cache a new test with a category", rox: { key: 'ae4ea7090e99' } do
      result = process runner: runner, new_test: true, previous_category: nil, category: categories[0]
      expect(cache).to have(10).items
      expect_cached written: 1, run: 1
      expect_cached project: result.test_info.project, written: 1, run: 1
      expect_cached project: result.test_info.project, category: result.category, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, written: 1, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
      expect_cached project: result.test_info.project, user: result.test_info.author, written: 1
      expect_cached category: result.category, user: result.test_info.author, written: 1
      expect_cached user: result.test_info.author, written: 1
    end

    it "should cache a new test whose runner is the same as the author", rox: { key: '41d0e9c1d181' } do
      result = process runner: author, new_test: true, previous_category: nil, category: categories[0]
      expect(cache).to have(7).items
      expect_cached written: 1, run: 1
      expect_cached project: result.test_info.project, written: 1, run: 1
      expect_cached project: result.test_info.project, category: result.category, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, written: 1, run: 1
      expect_cached category: result.category, written: 1, run: 1
      expect_cached category: result.category, user: result.runner, written: 1, run: 1
      expect_cached user: result.runner, written: 1, run: 1
    end

    it "should cache a new test with no category", rox: { key: 'adaa8b309960' } do
      result = process runner: runner, new_test: true, previous_category: nil, category: nil
      expect(cache).to have(10).items
      expect_cached written: 1, run: 1
      expect_cached project: result.test_info.project, written: 1, run: 1
      expect_cached project: result.test_info.project, category: nil, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: nil, written: 1, run: 1
      expect_cached category: nil, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
      expect_cached project: result.test_info.project, user: result.test_info.author, written: 1
      expect_cached category: nil, user: result.test_info.author, written: 1
      expect_cached user: result.test_info.author, written: 1
    end

    it "should cache an existing test with a category", rox: { key: 'cd4ff7383149' } do
      result = process runner: runner, new_test: false, previous_category: categories[0], category: categories[0]
      expect(cache).to have(7).items
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
    end

    it "should cache an existing test with no category", rox: { key: '535315ad4d31' } do
      result = process runner: runner, new_test: false, previous_category: nil, category: nil
      expect(cache).to have(7).items
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: nil, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: nil, run: 1
      expect_cached category: nil, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
    end

    it "should cache an existing test with a changed category", rox: { key: 'f3b474090323' } do
      result = process runner: runner, new_test: false, previous_category: categories[0], category: categories[1]
      expect(cache).to have(11).items
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, written: 1, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
      expect_cached category: result.category, user: result.test_info.author, written: 1
      expect_cached category: result.previous_category, written: -1
      expect_cached category: result.previous_category, project: result.test_info.project, written: -1
      expect_cached category: result.previous_category, user: result.test_info.author, written: -1
    end

    it "should cache an existing test with a changed category when it was nil before", rox: { key: 'fc7f9c943024' } do
      result = process runner: runner, new_test: false, previous_category: nil, category: categories[0]
      expect(cache).to have(11).items
      expect(result.category).not_to be_nil
      expect(result.previous_category).to be_nil
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, written: 1, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
      expect_cached category: result.category, user: result.test_info.author, written: 1
      expect_cached category: result.previous_category, written: -1
      expect_cached category: result.previous_category, project: result.test_info.project, written: -1
      expect_cached category: result.previous_category, user: result.test_info.author, written: -1
    end

    it "should cache an existing test with a changed category when it's nil now", rox: { key: '607fdb0f7b4b' } do
      result = process runner: runner, new_test: false, previous_category: categories[1], category: nil
      expect(cache).to have(11).items
      expect(result.category).to be_nil
      expect(result.previous_category).not_to be_nil
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, written: 1, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, written: 1, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
      expect_cached category: result.category, user: result.test_info.author, written: 1
      expect_cached category: result.previous_category, written: -1
      expect_cached category: result.previous_category, project: result.test_info.project, written: -1
      expect_cached category: result.previous_category, user: result.test_info.author, written: -1
    end

    it "should cache an existing deprecated test with a changed category", rox: { key: 'df3e915a2ee5' } do
      result = process runner: runner, new_test: false, deprecated: true, previous_category: categories[0], category: categories[1]
      expect(cache).to have(7).items
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
    end

    it "should cache an existing deprecated test with a changed category when it was nil before", rox: { key: 'ac9edc9d7511' } do
      result = process runner: runner, new_test: false, deprecated: true, previous_category: nil, category: categories[0]
      expect(cache).to have(7).items
      expect(result.category).not_to be_nil
      expect(result.previous_category).to be_nil
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
    end

    it "should cache an existing deprecated test with a changed category when it's nil now", rox: { key: 'fceda76d6d33' } do
      result = process runner: runner, new_test: false, deprecated: true, previous_category: categories[1], category: nil
      expect(cache).to have(7).items
      expect(result.category).to be_nil
      expect(result.previous_category).not_to be_nil
      expect_cached run: 1
      expect_cached project: result.test_info.project, run: 1
      expect_cached project: result.test_info.project, category: result.category, run: 1
      expect_cached project: result.test_info.project, user: result.runner, run: 1
      expect_cached category: result.category, run: 1
      expect_cached category: result.category, user: result.runner, run: 1
      expect_cached user: result.runner, run: 1
    end

    def expect_cached options = {}
      updates = { written: options.delete(:written).to_i, run: options.delete(:run).to_i }
      expect(cache[{ timezone: timezone, time: run_at }.merge(options)]).to eq(updates)
    end

    def process options = {}
      create(:test_result, { run_at: run_at, test_info: test }.merge(options)).tap do |result|
        described_class.new result, timezone, cache
      end
    end
  end
end

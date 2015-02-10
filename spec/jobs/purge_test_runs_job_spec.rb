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
require 'spec_helper'

describe PurgeTestRunsJob, probe_dock: { tags: :unit } do
  PURGE_TEST_RUNS_JOB_QUEUE = :purge
  let(:test_runs_lifespan){ 5 }
  subject{ described_class }

  before :each do
    ResqueSpec.reset!
    allow(Settings).to receive(:app).and_return(double(test_runs_lifespan: test_runs_lifespan))
  end

  it "should go in the #{PURGE_TEST_RUNS_JOB_QUEUE} queue", probe_dock: { key: 'dfc7369fafa4' } do
    expect(described_class.instance_variable_get('@queue').to_sym).to eq(PURGE_TEST_RUNS_JOB_QUEUE)
  end

  describe ".lock_workers" do

    it "should use the same lock as the payload processing job", probe_dock: { key: 'e6e35312a6e9' } do
      expect(subject.lock_workers).to eq(ProcessNextTestPayloadJob.name)
    end
  end

  describe ".number_remaining" do

    it "should count outdated test runs", probe_dock: { key: 'ca1ec2d41ada' } do
      create_test_runs
      expect(described_class.number_remaining).to eq(3)
    end

    it "should indicate that there is nothing to purge", probe_dock: { key: '728bcf7564fa' } do
      expect(described_class.number_remaining).to eq(0)
    end
  end

  describe ".data_lifespan" do
    it "should return the lifespan of test runs", probe_dock: { key: '15752398d178' } do
      expect(described_class.data_lifespan).to eq(5)
    end
  end

  describe ".perform" do
    let!(:data){ create_test_runs }
    let(:users){ data[:users] }
    let(:runs){ data[:runs] }
    let(:tests){ data[:tests] }
    let(:payloads){ data[:payloads] }
    let!(:purge_action){ create :purge_action, data_type: 'testRuns', created_at: 2.minutes.ago }

    before :each do

      allow(Rails.logger).to receive(:info)
      allow(Rails.application.events).to receive(:fire)

      expect(TestRun.count).to eq(5)
      expect(TestInfo.count).to eq(4)
      expect(TestResult.count).to eq(10)
      expect(TestPayload.count).to eq(6)

      subject.perform purge_action.id

      # FIXME: use a database that supports cascade deletes for testing
      TestInfo.joins(:effective_result).where('test_results.test_run_id IN (?)', runs[0, 3]).update_all effective_result_id: nil
      TestResult.where(test_run_id: runs[0, 3]).delete_all
      TestPayload.where(test_run_id: runs[0, 3]).delete_all
    end

    it "should delete outdated test runs and related data", probe_dock: { key: 'b0d44e50f658' } do

      # only the last 2 test runs should remain
      remaining_runs = TestRun.order('ended_at DESC').all.to_a
      expect(remaining_runs).to match_array(runs.reverse[0, 2])

      # no test should have been deleted
      expect(TestInfo.count).to eq(4)
      expect(TestInfo.all.to_a).to match_array(tests)

      # the results of the 3 outdated test runs should have been deleted
      expect(TestResult.count).to eq(4)
      expect(TestResult.all.to_a).to match_array(remaining_runs.collect(&:results).flatten)

      # the payloads of outdated test runs should have been deleted
      expect(TestPayload.count).to eq(2)
      expect(TestPayload.all.to_a).to match_array(payloads.reverse[0, 2])

      tests.each(&:reload)
      users.each(&:reload)

      # tests that were last run in one of the outdated runs should no longer have an effective result
      expect(tests[1].effective_result).not_to be_nil
      expect(tests[3].effective_result).not_to be_nil
      expect(tests[0].effective_result).to be_nil
      expect(tests[2].effective_result).to be_nil

      # users that last run one of the outdated runs should no longer have a last run
      expect(users[0].last_run).not_to be_nil
      expect(users[1].last_run).to be_nil
      expect(users[2].last_run).not_to be_nil
    end

    it "should log the number of purged runs", probe_dock: { key: 'cc0ec4d0c89c' } do
      expect(Rails.logger).to have_received(:info).with(/\APurged 3 outdated test runs in [0-9\.]+s\Z/)
    end

    it "should fire the purged:testRuns event", probe_dock: { key: '0571ebaea31e' } do
      expect(Rails.application.events).to have_received(:fire).with('purged:testRuns')
    end
  end

  def create_test_runs

    runs = []
    tests = []
    payloads = []
    users = [ create(:user), create(:other_user), create(:another_user) ]

    # test run creating two tests (outdated)
    test1 = create :test, key: create(:test_key, user: users.sample), runner: users[0], run_at: 3.months.ago
    test2 = create :test, key: create(:test_key, user: users.sample), test_run: test1.effective_result.test_run
    payloads << create(:processed_test_payload, user: users[0], test_run: test1.effective_result.test_run, received_at: test1.effective_result.test_run.ended_at)
    runs << test1.effective_result.test_run
    tests << test1 << test2

    # test run with no new test (outdated)
    run2 = create :test_run_with_uid, runner: users[1], ended_at: 2.months.ago
    create :test_result, runner: users[1], test_info: test1, test_run: run2, run_at: run2.ended_at
    create :test_result, runner: users[1], test_info: test2, test_run: run2, run_at: run2.ended_at, passed: false
    payloads << create(:processed_test_payload, user: users[1], test_run: run2, received_at: run2.ended_at)
    payloads << create(:processed_test_payload, user: users[1], test_run: run2, received_at: run2.ended_at + 2.minutes)
    runs << run2

    # test run creating a new test (outdated)
    test3 = create :test, key: create(:test_key, user: users.sample), runner: users[0], run_at: 1.month.ago
    test1_effective_result = create :test_result, runner: users[0], test_info: test1, test_run: test3.effective_result.test_run
    payloads << create(:processed_test_payload, user: users[0], test_run: test3.effective_result.test_run, received_at: test3.effective_result.test_run.ended_at)
    runs << test3.effective_result.test_run
    tests << test3

    # test run creating a new test
    test4 = create :test, key: create(:test_key, user: users.sample), runner: users[2], run_at: 4.days.ago
    create :test_result, runner: users[2], test_info: test2, test_run: test4.effective_result.test_run
    payloads << create(:processed_test_payload, user: users[2], test_run: test4.effective_result.test_run, received_at: test4.effective_result.test_run.ended_at)
    runs << test4.effective_result.test_run
    tests << test4

    # test run with no new test
    run5 = create :test_run, runner: users[0], ended_at: 2.days.ago
    test2_effective_result = create :test_result, runner: users[0], test_info: test2, test_run: run5, run_at: run5.ended_at, passed: false
    test4_effective_result = create :test_result, runner: users[0], test_info: test4, test_run: run5, run_at: run5.ended_at
    payloads << create(:processed_test_payload, user: users[0], test_run: run5, received_at: run5.ended_at)
    runs << run5

    users[0].update_attribute :last_run_id, runs[4].id
    users[1].update_attribute :last_run_id, runs[1].id
    users[2].update_attribute :last_run_id, runs[3].id

    test1.update_attribute :effective_result_id, test1_effective_result.id
    test2.update_attribute :effective_result_id, test2_effective_result.id
    test4.update_attribute :effective_result_id, test4_effective_result.id

    { users: users, runs: runs, tests: tests, payloads: payloads }
  end
end

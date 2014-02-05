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
require 'spec_helper'

describe ProcessApiPayloadJob::ProcessApiTestRun do

  let(:user){ create :user }
  let(:time_received){ Time.now }
  let(:processed_tests){ [ test_stub, test_stub, test_stub ] }
  let(:processed_tests_args){ processed_tests.dup }
  let :sample_payload do
    HashWithIndifferentAccess.new({
      u: "f47ac10b-58cc",
      g: "nightly",
      d: 3600000,
      r: [
        {
          j: fake_project_api_id,
          v: "1.0.2",
          t: [
            {
              k: fake_test_key
            },
            {
              k: fake_test_key
            }
          ]
        },
        {
          j: fake_project_api_id,
          v: "1.0.2",
          t: [
            {
              k: fake_test_key
            }
          ]
        }
      ]
    })
  end
  let(:cache){ {} }

  before :each do
    ProcessApiPayloadJob::ProcessApiTest.stub(:new){ |*args| processed_tests_args.shift }
    ROXCenter::Application.events.stub :fire
  end

  it "should process all tests in the test run", rox: { key: 'b6e8e058ea28' } do
    ProcessApiPayloadJob::ProcessApiTest.should_receive(:new).exactly(3).times
    expect(process_test_run.processed_tests).to match_array(processed_tests)
  end

  it "should enrich test data with project and version", rox: { key: '0c55f491f8e5' } do

    additional_test_data = sample_payload[:r][0].pick :j, :v
    ProcessApiPayloadJob::ProcessApiTest.should_receive(:new).ordered.with sample_payload[:r][0][:t][0].merge(additional_test_data), kind_of(TestRun), cache
    ProcessApiPayloadJob::ProcessApiTest.should_receive(:new).ordered.with sample_payload[:r][0][:t][1].merge(additional_test_data), kind_of(TestRun), cache

    additional_test_data = sample_payload[:r][1].pick :j, :v
    ProcessApiPayloadJob::ProcessApiTest.should_receive(:new).ordered.with sample_payload[:r][1][:t][0].merge(additional_test_data), kind_of(TestRun), cache

    process_test_run
  end

  it "should create a test run", rox: { key: 'cd4aa66e9735' } do
    run = nil
    expect{ run = process_test_run.test_run }.to change(TestRun, :count).by(1)
    expect(run.runner).to eq(user)
    expect(run.uid).to eq(sample_payload[:u])
    expect(run.group).to eq(sample_payload[:g])
    expect(run.ended_at).to eq(time_received)
    expect(run.duration).to eq(sample_payload[:d].to_i)
  end

  it "should create a test run without UID or group", rox: { key: '66f36d48f1f6' } do
    run = nil
    sample_payload.omit! :u, :g
    expect{ run = process_test_run.test_run }.to change(TestRun, :count).by(1)
    expect(run.runner).to eq(user)
    expect(run.uid).to be_nil
    expect(run.group).to be_nil
    expect(run.ended_at).to eq(time_received)
    expect(run.duration).to eq(sample_payload[:d].to_i)
  end

  it "should trigger an api:test_run event on the application", rox: { key: '06493acd8c6a' } do
    ROXCenter::Application.events.should_receive(:fire).with 'api:test_run', kind_of(ProcessApiPayloadJob::ProcessApiTestRun)
    process_test_run
  end

  it "should update the runner's last run", rox: { key: '62d2fe542535' } do
    run = process_test_run.test_run
    expect(user.last_run).to eq(run)
  end

  it "should correctly set the run's cached counters", rox: { key: '5fdac6019cb7' } do

    # Add 3 tests for a total of 6.
    3.times{ sample_payload[:r][1][:t] << { k: fake_test_key } }

    # 4 passed, 2 failed.
    # 2 inactive (1 passed, 1 failed).
    states = [
      { passed: true, active: true },
      { passed: true, active: true },
      { passed: true, active: true },
      { passed: false, active: true },
      { passed: false, active: false },
      { passed: true, active: false }
    ]

    ProcessApiPayloadJob::ProcessApiTest.stub(:new){ |*args| state = states.shift; test_stub state[:passed], state[:active] }

    process_test_run.test_run.tap do |run|
      expect(run.results_count).to eq(6)
      expect(run.passed_results_count).to eq(4)
      expect(run.inactive_results_count).to eq(2)
      expect(run.inactive_passed_results_count).to eq(1)
    end
  end

  context "with an existing test run" do

    let(:existing_run){ create :run_with_uid, runner: user, ended_at: 1.hour.ago }
    let(:cache){ { run: existing_run } }

    before :each do
      sample_payload.merge! u: existing_run.uid, g: existing_run.group
    end

    it "should re-use the same test run", rox: { key: '3a2390905ed1' } do
      run = nil
      expect{ run = process_test_run.test_run }.not_to change(TestRun, :count)
      expect(run).to eq(existing_run)
      expect(run.runner).to eq(user)
      expect(run.uid).to eq(existing_run.uid)
      expect(run.group).to eq(existing_run.group)
      expect(run.ended_at).to eq(time_received)
      expect(run.duration).to eq(sample_payload[:d].to_i)
    end

    it "should update the test run", rox: { key: 'f3d4792006ac' } do
      sample_payload[:g] = 'Another group'
      sample_payload[:d] = sample_payload[:d] * 2
      process_test_run.test_run.tap do |run|
        expect(run.group).to eq(sample_payload[:g])
        expect(run.ended_at).to eq(time_received)
        expect(run.duration).to eq(sample_payload[:d].to_i)
      end
    end

    it "should correctly set the run's cached counters", rox: { key: 'af6fdab108f9' } do

      existing_run.update_attribute :results_count, 4
      existing_run.update_attribute :passed_results_count, 3
      existing_run.update_attribute :inactive_results_count, 2
      existing_run.update_attribute :inactive_passed_results_count, 1

      # Add 3 tests for a total of 6.
      3.times{ sample_payload[:r][1][:t] << { k: fake_test_key } }

      # Stub passed and active properties.
      states = [
        { passed: true, active: true },
        { passed: true, active: true },
        { passed: true, active: true },
        { passed: false, active: true },
        { passed: false, active: false },
        { passed: true, active: false }
      ]

      ProcessApiPayloadJob::ProcessApiTest.stub(:new){ |*args| state = states.shift; test_stub state[:passed], state[:active] }

      process_test_run.test_run.tap do |run|
        expect(run.results_count).to eq(10)
        expect(run.passed_results_count).to eq(7)
        expect(run.inactive_results_count).to eq(4)
        expect(run.inactive_passed_results_count).to eq(2)
      end
    end
  end

  private

  def fake_project_api_id
    SecureRandom.hex 6
  end

  def fake_test_key
    SecureRandom.hex 6
  end

  def test_stub passed = true, active = true
    double test_result: double(passed: passed, active: active)
  end

  def process_test_run data = sample_payload, runner = user, time_received = time_received, cache = cache
    ProcessApiPayloadJob::ProcessApiTestRun.new data, runner, time_received, cache
  end
end

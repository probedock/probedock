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

describe CountDeprecationJob do
  COUNT_DEPRECATION_JOB_QUEUE = 'metrics:test_counters'

  before :each do
    ResqueSpec.reset!
  end
  
  it "should go in the #{COUNT_DEPRECATION_JOB_QUEUE} queue", rox: { key: '3a27ee39a081' } do
    expect(described_class.instance_variable_get('@queue')).to eq(COUNT_DEPRECATION_JOB_QUEUE)
  end

  describe "events" do
    let(:deprecation_double){ double }
    let(:timezones){ [ 'UTC', 'Bern' ] }
    before(:each){ allow(ROXCenter::Application).to receive(:metrics_timezones).and_return(timezones) }

    it "should enqueue a job on the test:deprecated event", rox: { key: '490db0b2e66a' } do
      expect(described_class).to receive(:enqueue_deprecations).with([ deprecation_double ], timezones: timezones)
      described_class.fire 'test:deprecated', deprecation_double
    end

    it "should enqueue a job on the test:undeprecated event", rox: { key: 'fd13a157d54f' } do
      expect(described_class).to receive(:enqueue_deprecations).with([ deprecation_double ], timezones: timezones)
      described_class.fire 'test:undeprecated', deprecation_double
    end
  end

  describe ".enqueue_deprecation" do

    it "should enqueue a job with a deprecated test", rox: { key: '56f6f6191ca3' } do
      deprecated_at = 2.days.ago
      test = create :test, deprecated_at: deprecated_at
      described_class.enqueue_deprecations [ test.deprecation ], foo: 'bar'
      expect(described_class).to have_queued([ test.deprecation.id ], foo: 'bar').in(COUNT_DEPRECATION_JOB_QUEUE)
      expect(described_class).to have_queue_size_of(1)
    end
    
    it "should enqueue a job with an undeprecated test", rox: { key: '73e4f5f519ff' } do
      test = create :test
      deprecation = create :deprecation, deprecated: false, test_info: test
      described_class.enqueue_deprecations [ deprecation ], foo: 'bar'
      expect(described_class).to have_queued([ deprecation.id ], foo: 'bar').in(COUNT_DEPRECATION_JOB_QUEUE)
      expect(described_class).to have_queue_size_of(1)
    end

    it "should enqueue a job with multiple deprecations", rox: { key: '1c163bec9352' } do
      user = create :user
      tests = Array.new(3){ |i| create :test, key: create(:test_key, user: user), deprecated_at: i.days.ago }
      deprecations = tests.collect &:deprecation
      described_class.enqueue_deprecations deprecations, foo: 'bar'
      expect(described_class).to have_queued(deprecations.collect(&:id), foo: 'bar').in(COUNT_DEPRECATION_JOB_QUEUE)
      expect(described_class).to have_queue_size_of(1)
    end

    it "should log information about the test", rox: { key: 'de215dfad87f' } do
      test = create :test, deprecated_at: 2.days.ago
      expect(Rails.logger).to receive(:debug).with(/updating test counters.*1 deprecation.*/i)
      described_class.enqueue_deprecations [ test.deprecation ], foo: 'bar'
    end
  end

  describe ".perform" do
    let(:user){ create :user }
    let(:deprecated_at){ 3.days.ago }
    let(:deprecated_test){ create :test, key: create(:test_key, user: user), deprecated_at: deprecated_at }

    it "should instantiate a job with loaded data", rox: { key: '45622943f63f' } do
      allow(described_class).to receive(:new).and_return(nil)
      expect(described_class).to receive(:new) do |*args|
        expect(args[0]).to eq(deprecated_test.deprecation)
        expect(args[1]).to eq(HashWithIndifferentAccess.new(foo: 'bar'))
      end
      described_class.perform [ deprecated_test.deprecation_id ], foo: 'bar'
    end

    it "should instantiate multiple jobs with loaded data", rox: { key: '40a201539841' } do
      deprecated_tests = [ deprecated_test ] + Array.new(2){ |i| create :test, key: create(:test_key, user: user), deprecated_at: i.days.ago }
      allow(described_class).to receive(:new).and_return(nil)
      deprecated_tests.each do |test|
        expect(described_class).to receive(:new).ordered do |*args|
          expect(args[0]).to eq(test.deprecation)
          expect(args[1]).to eq(HashWithIndifferentAccess.new(foo: 'bar'))
        end
      end
      described_class.perform deprecated_tests.collect{ |t| t.deprecation_id }, foo: 'bar'
    end

    it "should trigger a test:counters event on the application", rox: { key: 'd311529e3b65' } do
      allow(described_class).to receive(:new).and_return(nil)
      test = deprecated_test # create test before so that user:created event is skipped
      expect(Rails.application.events).to receive(:fire).with('test:counters')
      described_class.perform [ test.deprecation_id ], foo: 'bar'
    end
  end

  describe "processing" do
    let(:time){ 4.days.ago }
    let(:runner){ create :user }
    let(:author){ create :another_user }
    let(:test_key){ create :test_key, user: author }
    let(:project){ create :project }
    let(:category){ create :category }
    let(:test){ create :test, key: test_key, project: project, category: category, deprecated_at: time, run_at: time - 3.days, runner: runner }
    let(:deprecation){ test.deprecation }
    let(:timezones){ [ 'Bern' ] }
    let(:job_options){ { timezones: timezones } }
    let(:measures){ [] }
    before :each do
      allow(TestCounter).to receive(:measure) do |options|
        measures << options
      end
    end
  
    it "should fail with no timezones", rox: { key: '4e12e642ba40' } do
      expect{ described_class.new deprecation, {} }.to raise_error(StandardError, ":timezones option is missing")
    end

    shared_examples_for "a deprecation job" do

      it "should decrease all matching test counters by one" do
        described_class.new deprecation.tap{ |d| d.deprecated = true }, job_options

        caches = measures.collect{ |m| m.delete :cache }.compact
        expect(caches).to have(7).items
        expect(caches.last).to eq({})
        caches.first(6).each{ |c| expect(c).to be(caches.last) }

        expect(measures).to have(7).items
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern')
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', project: expected_project)
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', project: expected_project, category: expected_category)
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', project: expected_project, user: expected_user)
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', category: expected_category)
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', category: expected_category, user: expected_user)
        expect(measures).to include(time: time, deprecated: 1, timezone: 'Bern', user: expected_user)
      end

      it "should increase all matching test counters by one if the test was undeprecated" do
        deprecation.update_attribute :deprecated, false
        test.update_attribute :deprecation_id, nil
        described_class.new deprecation, job_options

        caches = measures.collect{ |m| m.delete :cache }.compact
        expect(caches).to have(7).items
        expect(caches.last).to eq({})
        caches.first(6).each{ |c| expect(c).to be(caches.last) }

        expect(measures).to have(7).items
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern')
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', project: expected_project)
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', project: expected_project, category: expected_category)
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', project: expected_project, user: expected_user)
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', category: expected_category)
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', category: expected_category, user: expected_user)
        expect(measures).to include(time: time, deprecated: -1, timezone: 'Bern', user: expected_user)
      end
    end

    describe "with no following result", rox: { key: '71f8deee8d93', grouped: true } do
      let(:expected_project){ project }
      let(:expected_category){ category }
      let(:expected_user){ author }
      it_should_behave_like "a deprecation job"
    end

    describe "with no category", rox: { key: '124751f0aba5', grouped: true } do
      let(:category){ nil }
      let(:expected_project){ project }
      let(:expected_category){ nil }
      let(:expected_user){ author }
      it_should_behave_like "a deprecation job"
    end

    describe "with a following result in another category", rox: { key: '4bcf621b7a31', grouped: true } do
      let(:other_category){ create :category }
      let!(:following_result){ create :result, runner: runner, test_info: test, previous_category: other_category, category: category, run_at: time + 2.days }
      let!(:future_result){ create :result, runner: author, test_info: test, previous_category: category, category: other_category, run_at: time + 5.days }
      let(:expected_project){ project }
      let(:expected_category){ category } # category should remain the same as it was linked to the (un)deprecation
      let(:expected_user){ author }
      it_should_behave_like "a deprecation job"

      describe "being nil" do
        let(:other_category){ nil }
        it_should_behave_like "a deprecation job"
      end
    end
  end
end

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

describe TestCounter do
  TEST_COUNTER_CACHE_BASE = 'metrics:test_counters'

  describe ".cache_key" do

    it "should return a cache key with the correct prefix", rox: { key: '6e4c80af513d' } do
      %w(foo bar baz).each do |key|
        expect(described_class.cache_key(key)).to eq("#{TEST_COUNTER_CACHE_BASE}:#{key}")
      end
    end
  end

  describe ".measure" do
    let(:cache){ {} }
    let(:now){ Time.utc 2011, 12, 31, 23, 30, 0 }
    let(:timezone){ 'Bern' }
    let(:counter_sample){ { cache: cache, time: now, timezone: timezone, written: rand(100), run: rand(100) } }
    let(:user){ create(:user).tap{ |u| u.update_attribute :metric_key, 'u' } }
    let(:project){ create(:project).tap{ |p| p.update_attribute :metric_key, 'p' } }
    let(:category){ create(:category).tap{ |c| c.update_attribute :metric_key, 'c' } }

    it "should fail with no time", rox: { key: '2122bf48a8e6' } do
      expect{ described_class.measure counter_sample.tap{ |h| h.delete :time } }.to raise_error(StandardError, "Time is missing")
    end

    it "should fail with no timezone", rox: { key: '961a1f6560b5' } do
      expect{ described_class.measure counter_sample.tap{ |h| h.delete :timezone } }.to raise_error(StandardError, "Timezone is missing")
    end

    it "should fail with no counter updates", rox: { key: '07635281abe0' } do
      expect{ described_class.measure counter_sample.tap{ |h| h.delete :written; h.delete :run } }.to raise_error(StandardError, "No counter updates")
    end

    it "should correctly create test counters", rox: { key: '54bb6914ee1d' } do
      
      expect{ measure 'Bern', Time.utc(2011, 12, 31, 23, 30), written: 2, run: 14 }.to change(TestCounter, :count).by(1)
      expect_counter "Bern:2012-01-01:0:", 'Bern', Time.utc(2011, 12, 31, 23), 0, written: 2, run: 14

      expect{ measure 'UTC', Time.utc(2012, 1, 1), user: user, written: 3 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2012-01-01:1:u", 'UTC', Time.utc(2012, 1, 1), 1, user: user, written: 3

      expect{ measure 'UTC', Time.utc(2011, 12, 31, 23, 59, 59), category: category, run: 256 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2011-12-31:2:c", 'UTC', Time.utc(2011, 12, 31), 2, category: category, run: 256

      expect{ measure 'Hawaii', Time.utc(2012, 1, 1), user: user, category: category, run: 1 }.to change(TestCounter, :count).by(1)
      expect_counter "Hawaii:2011-12-31:3:u-c", 'Hawaii', Time.utc(2011, 12, 31, 10), 3, user: user, category: category, run: 1
      
      expect{ measure 'Bern', Time.utc(2011, 12, 31, 23, 30), project: project, written: 24, run: 100 }.to change(TestCounter, :count).by(1)
      expect_counter "Bern:2012-01-01:4:p", 'Bern', Time.utc(2011, 12, 31, 23), 4, project: project, written: 24, run: 100
      
      expect{ measure 'Minsk', Time.utc(2012, 1, 1, 22, 30), user: user, project: project, run: 100 }.to change(TestCounter, :count).by(1)
      expect_counter "Minsk:2012-01-02:5:u-p", 'Minsk', Time.utc(2012, 1, 1, 21), 5, user: user, project: project, run: 100

      expect{ measure 'UTC', Time.utc(2012, 7, 12, 3, 4, 5), category: category, project: project, written: 1 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2012-07-12:6:c-p", 'UTC', Time.utc(2012, 7, 12), 6, category: category, project: project, written: 1

      expect{ measure 'UTC', Time.utc(2011, 11, 11), category: nil, run: 1 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2011-11-11:2:$", 'UTC', Time.utc(2011, 11, 11), 2, category: nil, run: 1

      expect{ measure 'UTC', Time.utc(2011, 11, 11), category: nil, project: project, run: 2 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2011-11-11:6:$-p", 'UTC', Time.utc(2011, 11, 11), 6, category: nil, project: project, run: 2

      expect{ measure 'UTC', Time.utc(2011, 11, 11), user: user, category: nil, run: 3 }.to change(TestCounter, :count).by(1)
      expect_counter "UTC:2011-11-11:3:u-$", 'UTC', Time.utc(2011, 11, 11), 3, user: user, category: nil, run: 3
    end

    it "should correctly update an existing test counter", rox: { key: '0e006dfe8ae2' } do
      expect{ measure 'Bern', Time.utc(2012, 1, 1), user: user, written: 24, run: 33 }.to change(TestCounter, :count).by(1)
      expect_counter "Bern:2012-01-01:1:u", 'Bern', Time.utc(2011, 12, 31, 23), 1, user: user, written: 24, run: 33
      expect{ measure 'Bern', Time.utc(2012, 1, 1), user: user, written: 42, run: 66 }.not_to change(TestCounter, :count)
      expect_counter "Bern:2012-01-01:1:u", 'Bern', Time.utc(2011, 12, 31, 23), 1, user: user, written: 66, run: 99
    end

    it "should not attempt to create a test counter if already cached", rox: { key: '0d4e80543241' } do

      counter = TestCounter.new.tap do |c|
        c.unique_token = 'UTC:2012-01-02:0:'
        c.timestamp = Time.utc 2012, 1, 2
        c.timezone = 'UTC'
        c.mask = 0
        c.run_counter = 24
        c.save!
      end

      described_class.cache_token counter.unique_token, 'UTC'

      expect(TestCounter).not_to receive(:new)
      expect{ measure 'UTC', Time.utc(2012, 1, 2), written: 6, run: 42 }.not_to change(TestCounter, :count)
      expect_counter "UTC:2012-01-02:0:", 'UTC', Time.utc(2012, 1, 2), 0, written: 6, run: 66
    end

    it "should not fail if a test counter exists but is not cached", rox: { key: '805ee1b603de' } do

      counter = TestCounter.new.tap do |c|
        c.unique_token = 'UTC:2012-01-03:0:'
        c.timestamp = Time.utc 2012, 1, 3
        c.timezone = 'UTC'
        c.mask = 0
        c.run_counter = 24
        c.save!
      end

      expect{ measure 'UTC', Time.utc(2012, 1, 3), written: 30, run: 6 }.not_to change(TestCounter, :count)
      expect_counter "UTC:2012-01-03:0:", 'UTC', Time.utc(2012, 1, 3), 0, written: 30, run: 30
    end

    it "should cache tokens", rox: { key: '891c0beb0ca1' } do

      measure 'UTC', Time.utc(2011, 12, 31, 23, 59, 59), category: category, run: 1
      measure 'Hawaii', Time.utc(2012, 1, 1), user: user, category: category, run: 2
      measure 'Bern', Time.utc(2011, 12, 31, 23, 30), project: project, run: 3
      measure 'Minsk', Time.utc(2012, 1, 1, 22, 30), user: user, project: project, run: 4

      expect(described_class.token_known?("UTC:2011-12-31:2:c")).to be(true)
      expect(described_class.token_known?("Hawaii:2011-12-31:3:u-c")).to be(true)
      expect(described_class.token_known?("Bern:2012-01-01:4:p")).to be(true)
      expect(described_class.token_known?("Minsk:2012-01-02:5:u-p")).to be(true)
    end

    def expect_counter token, timezone, timestamp, mask, options = {}
      described_class.where(unique_token: token).first.tap do |counter|
        expect(counter).not_to be_nil
        expect(counter.timezone).to eq(timezone)
        expect(counter.timestamp).to eq(timestamp)
        expect(counter.mask).to eq(mask)
        expect(counter.user).to(options.key?(:user) ? eq(options[:user]) : be_nil)
        expect(counter.category).to(options.key?(:category) ? eq(options[:category]) : be_nil)
        expect(counter.project).to(options.key?(:project) ? eq(options[:project]) : be_nil)
        expect(counter.written_counter).to eq(options[:written].to_i)
        expect(counter.run_counter).to eq(options[:run].to_i)
        expect(counter.total_written).to be_nil
        expect(counter.total_run).to be_nil
      end
    end

    def measure timezone, time, options
      described_class.measure options.merge(cache: cache, timezone: timezone, time: time)
    end
  end

  describe "recomputing" do
    let(:timezones){ [ 'Bern' ] }
    let!(:old_counters){ Array.new(3){ |i| create :test_counter, timestamp: i.days.ago } }
    before :each do
      ResqueSpec.reset!
      allow(CountTestsJob).to receive(:enqueue_runs).and_return(nil)
      allow(CountDeprecationJob).to receive(:enqueue_deprecations).and_return(nil)
    end

    it "should delete existing counters", rox: { key: 'c54f3b3fa06c' } do
      expect(described_class.count).to eq(3)
      recompute
      expect(described_class.count).to eq(0)
    end

    it "should clean the token cache", rox: { key: '4e739ed3fd54' } do
      token = 'Bern:2012-01-01:0:'
      described_class.cache_token token, Time.now
      expect(described_class.token_known?(token)).to be(true)
      recompute
      expect(described_class.token_known?(token)).to be(false)
    end

    it "should not queue anything if there is no data", rox: { key: 'b5b2ce6d9d0a' } do
      recompute
      expect(CountTestsJob).to have_queue_size_of(0)
      expect(CountDeprecationJob).to have_queue_size_of(0)
    end

    it "should be done preparing when exiting the recompute method", rox: { key: 'b37089337352' } do
      recompute
      expect(described_class.preparing?).to be(false)
    end

    it "should stop recomputing if there is no data", rox: { key: 'f7a31e1610e0' } do
      recompute
      expect(described_class.recomputing?).to be(false)
    end

    describe "with data" do
      
      let(:user){ create :user }
      let! :tests do
        [
          create(:test, key: create(:test_key, user: user), runner: user, run_at: 80.hours.ago),
          create(:test, key: create(:test_key, user: user), runner: user, run_at: 75.hours.ago, deprecated_at: 20.hours.ago),
          create(:test, key: create(:test_key, user: user), runner: user, run_at: 50.hours.ago),
          create(:test, key: create(:test_key, user: user), runner: user, run_at: 8.hours.ago, deprecated_at: 4.hours.ago),
          create(:test, key: create(:test_key, user: user), runner: user, run_at: 7.hours.ago)
        ]
      end
      let(:test_runs){ tests.collect{ |t| t.effective_result.test_run } }

      it "should start recomputing", rox: { key: '2785845e9558' } do
        recompute
        expect(described_class.recomputing?).to be(true)
      end

      it "should queue a batch job for deprecated tests", rox: { key: '73bf31307244' } do
        expect(CountDeprecationJob).to receive(:enqueue_deprecations).ordered.with([ tests[1].deprecation, tests[3].deprecation ], timezones: timezones)
        expect(CountDeprecationJob).not_to receive(:enqueue_deprecations).ordered
        recompute
      end

      it "should queue multiple batch jobs for deprecated tests when there are too many", rox: { key: '00c095e4bad8' } do
        stub_const "TestCounter::DEPRECATION_BATCH_SIZE", 1
        expect(CountDeprecationJob).to receive(:enqueue_deprecations).ordered.with([ tests[1].deprecation ], timezones: timezones)
        expect(CountDeprecationJob).to receive(:enqueue_deprecations).ordered.with([ tests[3].deprecation ], timezones: timezones)
        expect(CountDeprecationJob).not_to receive(:enqueue_deprecations).ordered
        recompute
      end

      it "should queue a job for each day with test runs", rox: { key: '9aab2a355a1c' } do

        now = Time.now

        expect(CountTestsJob).to receive(:enqueue_runs).ordered.with([ test_runs[0], test_runs[1] ], max_time: now.to_f, timezones: timezones)
        expect(CountTestsJob).to receive(:enqueue_runs).ordered.with([ test_runs[2] ], max_time: now.to_f, timezones: timezones)
        expect(CountTestsJob).to receive(:enqueue_runs).ordered.with([ test_runs[3], test_runs[4] ], max_time: now.to_f, timezones: timezones)
        expect(CountTestsJob).not_to receive(:enqueue_runs).ordered
        expect(CountTestsJob).not_to receive(:enqueue_results)

        allow(Time).to receive(:now).and_return(now)
        recompute
      end

      it "should be preparing inside the recompute method", rox: { key: 'e2884248b433' } do
        allow(CountDeprecationJob).to receive(:enqueue_deprecations){ expect(described_class.preparing?).to be(true) }
        allow(CountTestsJob).to receive(:enqueue_runs){ expect(described_class.preparing?).to be(true) }
        recompute
      end

      it "should not allow recomputing if already in progress", rox: { key: 'a2c73531db3c' } do
        expect(recompute).to be(true)
        expect(recompute).to be(false)
      end

      it "should be done preparing when exiting the recompute method", rox: { key: 'c0d1a6c3c691' } do
        recompute
        expect(described_class.preparing?).to be(false)
      end

      it "should stop with clear_computing", rox: { key: '5be8ef7d3d48' } do
        TestCounter.update_remaining_results 1234
        recompute
        described_class.clear_computing
        expect(described_class.preparing?).to be(false)
        expect(described_class.recomputing?).to be(false)
        expect(described_class.remaining_results).to eq(0)
      end
    end
    
    def recompute
      described_class.recompute! timezones
    end
  end

  describe "cached tokens" do
    let(:token){ 'Bern:2012-01-01:0:' }
    
    it "should not know a token by default", rox: { key: '17b54ec2fd1c' } do
      expect(described_class.token_known?(token)).to be(false)
    end

    it "should cache a token with a timestamp", rox: { key: '0f0365ae0b45' } do
      described_class.cache_token token, 14.hours.ago
      expect(described_class.token_known?(token)).to be(true)
    end

    it "should clean tokens older than one day", rox: { key: '9d7a292fdfe2' } do
      described_class.cache_token token, 25.hours.ago
      described_class.clean_token_cache
      expect(described_class.token_known?(token)).to be(false)
    end

    it "should clean all tokens if specified", rox: { key: '402836bc9b2a' } do
      described_class.cache_token token, 12.hours.ago
      described_class.clean_token_cache true
      expect(described_class.token_known?(token)).to be(false)
    end
  end

  describe "remaining results" do
    
    it "should be zero by default", rox: { key: '0c1f44b7ce96' } do
      expect(described_class.remaining_results).to eq(0)
    end

    it "should update by the specified increment", rox: { key: '3b716e29f8a0' } do
      described_class.update_remaining_results 1
      expect(described_class.remaining_results).to eq(1)
      described_class.update_remaining_results 2
      expect(described_class.remaining_results).to eq(3)
      described_class.update_remaining_results 3
      expect(described_class.remaining_results).to eq(6)
      described_class.update_remaining_results -4
      expect(described_class.remaining_results).to eq(2)
    end

    it "should be cleared with nil", rox: { key: 'b0c910c2969b' } do
      described_class.update_remaining_results 2
      described_class.update_remaining_results nil
      expect(described_class.remaining_results).to eq(0)
    end
  end

  describe ".mask_for" do
    subject{ described_class }

    it "should generate correct masks", rox: { key: 'f645bc09fa8d' } do
      expect(subject.mask_for).to eq(0)
      expect(subject.mask_for(:user)).to eq(1)
      expect(subject.mask_for(:category)).to eq(2)
      expect(subject.mask_for(:user, :category)).to eq(3)
      expect(subject.mask_for(:project)).to eq(4)
      expect(subject.mask_for(:project, :user)).to eq(5)
      expect(subject.mask_for(:project, :category)).to eq(6)
      expect(subject.mask_for(:project, :category, :user)).to eq(7)
    end
  end

  context "validations" do
    it(nil, rox: { key: '07c73fd0c35a' }){ should validate_presence_of(:timezone) }
    it(nil, rox: { key: 'bf4726ccd07b' }){ should validate_presence_of(:timestamp) }
    it(nil, rox: { key: '0897a85cb0d2' }){ should validate_presence_of(:mask) }
    it(nil, rox: { key: '82843b3c5dd5' }){ should validate_numericality_of(:mask).only_integer }
    it(nil, rox: { key: 'de686f4db890' }){ should allow_value(0, 1, 2, 3, 4, 5, 6).for(:mask) }
    it(nil, rox: { key: 'f78dead2e956' }){ should_not allow_value(-99, -1).for(:mask) }
    it(nil, rox: { key: 'a8f84069a3ad' }){ should validate_presence_of(:unique_token) }

    context "with an existing counter" do
      let!(:test_counter){ create :test_counter }
      it(nil, rox: { key: '45b12beb6f0e' }){ should validate_uniqueness_of(:unique_token) }

      context "with quick validation" do
        before(:each){ subject.quick_validation = true }

        it "should not validate the uniqueness of the unique token", rox: { key: 'c00f69bfebcb' } do
          %w(timezone timestamp mask unique_token).each{ |attr| subject.send "#{attr}=", test_counter.send(attr) }
          expect{ subject.save! }.to raise_unique_error
        end
      end
    end
  end

  context "associations" do
    it(nil, rox: { key: '513f054b5416' }){ should belong_to(:user) }
    it(nil, rox: { key: '6930f305d838' }){ should belong_to(:category) }
    it(nil, rox: { key: '7790acb75f1d' }){ should belong_to(:project) }
  end

  context "database table" do
    it(nil, rox: { key: '12052905fff3' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '70f610787cdb' }){ should have_db_column(:timezone).of_type(:string).with_options(null: false, limit: 30) }
    it(nil, rox: { key: '05ee93a70849' }){ should have_db_column(:timestamp).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '16d4518c8185' }){ should have_db_column(:mask).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'e7c775b8927e' }){ should have_db_column(:unique_token).of_type(:string).with_options(null: false, limit: 100) }
    it(nil, rox: { key: '31548d0c94ba' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '5e6f1645638e' }){ should have_db_column(:category_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '0b586eebb4ca' }){ should have_db_column(:project_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: 'd5592cc4e155' }){ should have_db_column(:written_counter).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, rox: { key: '9dd151eaf810' }){ should have_db_column(:run_counter).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, rox: { key: 'db48ccd5571a' }){ should have_db_column(:deprecated_counter).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, rox: { key: '84fb55cce52e' }){ should have_db_column(:total_written).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '8f12f7e23b93' }){ should have_db_column(:total_run).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: 'cf34c9a567c5' }){ should have_db_column(:total_deprecated).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: 'de5b43b8d66f' }){ should have_db_index(:unique_token).unique(true) }
    it(nil, rox: { key: '9074d8179af1' }){ should have_db_index([ :timezone, :timestamp, :mask ]) }
  end
end

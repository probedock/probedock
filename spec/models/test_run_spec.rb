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

describe TestRun, rox: { tags: :unit } do

  let(:user){ create :user }
  let(:grouped_runs){ Array.new(5){ |i| create :run, runner: user, ended_at: (5 - i).days.ago, group: i % 2 == 0 ? 'nightly' : 'daily' } }

  it "should clear its report cache when saved", rox: { key: '5f809c05a02a' } do
    allow(ReportCache).to receive(:clear)
    run = create :run
    expect(ReportCache).to receive(:clear).with(run.id)
    run.save
  end

  context ".report" do

    it "should return a test run with all details eager loaded", rox: { key: '2d3b27d9838c' } do

      projects = [ create(:project, name: 'Project A'), create(:project, name: 'Project B') ]
      cat1, cat2 = create(:category, name: 'foo'), create(:category, name: 'bar')
      categories = [ cat1, cat1, nil, cat2, nil ]
      names = [ 'Test', 'Test', 'Test B', 'Test', 'Test A' ]

      keys = Array.new(5){ |i| create :key, user: user, project: projects[(i % 2 - 1).abs] }
      run = create :run, runner: user
      tests = Array.new(keys.length){ |i| create :test, key: keys[i], name: names.shift, category: categories.shift, test_run: run }

      report = TestRun.report run.id
      expect(report).to eq(run)
      expect(report).not_to query_the_database.when_calling(:results)
    end
  end

  context "#ordered_results" do

    it "should return the results ordered by project, category and test name", rox: { key: 'bd3e379ee226' } do

      projects = [ create(:project, name: 'Project A'), create(:project, name: 'Project B') ]
      cat1, cat2 = create(:category, name: 'foo'), create(:category, name: 'bar')
      categories = [ cat1, cat1, nil, cat2, nil ]
      names = [ 'Test', 'Test', 'Test B', 'Test', 'Test A' ]

      keys = Array.new(5){ |i| create :key, user: user, project: projects[(i % 2 - 1).abs] }
      run = create :run, runner: user
      tests = Array.new(keys.length){ |i| create :test, key: keys[i], name: names.shift, category: categories.shift, test_run: run }

      expect(run.ordered_results.collect(&:test_info)).to eq([ tests[3], tests[1], tests[0], tests[4], tests[2] ])
    end
  end

  context ".with_report_data" do

    it "should return a test run with all details included", rox: { key: 'a02815e3a91e' } do
      run = TestRun.with_report_data.find create(:run).id
      expect(run).not_to query_the_database.when_calling(:to_client_hash).with(type: :report)
    end
  end

  context ".reports_cache" do
    
    it "should return the reports cache", rox: { key: '5c5ae1d49caf' } do
      expect(TestRun.reports_cache.class).to eq(ReportCache)
    end
  end

  context ".reports_cache_size" do

    it "should return a proc which returns the reports cache size in the app settings", rox: { key: 'f025a90a2881' } do
      expect(TestRun.reports_cache_size.call).to eq(Settings.app.reports_cache_size)
      Settings::App.first.tap{ |s| s.reports_cache_size = 42 }.save
      expect(TestRun.reports_cache_size.call).to eq(42)
    end
  end

  context "#previous_in_group" do

    it "should return the previous run of the same group if any", rox: { key: '69379b166ae5' } do
      expect(grouped_runs[0].previous_in_group).to be_nil
      expect(grouped_runs[1].previous_in_group).to be_nil
      expect(grouped_runs[2].previous_in_group).to eq(grouped_runs[0])
      expect(grouped_runs[3].previous_in_group).to eq(grouped_runs[1])
      expect(grouped_runs[4].previous_in_group).to eq(grouped_runs[2])
    end
  end

  context "#previous_in_group?" do

    it "should indicate whether there is a previous run of the same group", rox: { key: 'e8fee7db607a' } do
      expect(grouped_runs[0].previous_in_group?).to be(false)
      expect(grouped_runs[1].previous_in_group?).to be(false)
      expect(grouped_runs[2].previous_in_group?).to be(true)
      expect(grouped_runs[3].previous_in_group?).to be(true)
      expect(grouped_runs[4].previous_in_group?).to be(true)
    end
  end

  context "#next_in_group" do

    it "should return the next run of the same group if any", rox: { key: 'cc979a5bba68' } do
      expect(grouped_runs[0].next_in_group).to eq(grouped_runs[2])
      expect(grouped_runs[1].next_in_group).to eq(grouped_runs[3])
      expect(grouped_runs[2].next_in_group).to eq(grouped_runs[4])
      expect(grouped_runs[3].next_in_group).to be_nil
      expect(grouped_runs[4].next_in_group).to be_nil
    end
  end

  context "#next_in_group?" do

    it "should indicate whether there is next run of the same group", rox: { key: '9cfcbffa63bc' } do
      expect(grouped_runs[0].next_in_group?).to be(true)
      expect(grouped_runs[1].next_in_group?).to be(true)
      expect(grouped_runs[2].next_in_group?).to be(true)
      expect(grouped_runs[3].next_in_group?).to be(false)
      expect(grouped_runs[4].next_in_group?).to be(false)
    end
  end

  context ".groups" do

    it "should return distinct test run groups", rox: { key: '0126127d63ac' } do
      grouped_runs
      create :run, runner: user, group: 'yearly'
      expect(TestRun.groups).to match_array([ 'daily', 'nightly', 'yearly' ])
    end
  end

  context "validations" do
    it(nil, rox: { key: '198348319df4' }){ should ensure_length_of(:uid).is_at_most(255) }
    it(nil, rox: { key: 'a6fcf66b461e' }){ should ensure_length_of(:group).is_at_most(255) }
    it(nil, rox: { key: '6d6aef3391fa' }){ should validate_presence_of(:ended_at) }
    it(nil, rox: { key: '821572c9e43d' }){ should validate_presence_of(:duration) }
    it(nil, rox: { key: '2d78632732d6' }){ should validate_numericality_of(:duration).only_integer }
    it(nil, rox: { key: '5c64d90c7502' }){ should allow_value(0, 10000, 3600000).for(:duration) }
    it(nil, rox: { key: 'e46bc638cbeb' }){ should_not allow_value(-1, -42, -66).for(:duration) }
    it(nil, rox: { key: '428f1b3acc7c' }){ should validate_presence_of(:runner) }
    it(nil, rox: { key: 'd0bfedf4a086' }){ should validate_numericality_of(:results_count).only_integer }
    it(nil, rox: { key: '736fdcdd58a6' }){ should validate_numericality_of(:passed_results_count).only_integer }
    it(nil, rox: { key: '9c573126347e' }){ should validate_numericality_of(:inactive_results_count).only_integer }
    it(nil, rox: { key: 'd9954da8ec11' }){ should validate_numericality_of(:inactive_passed_results_count).only_integer }

    context "with an existing test run" do

      before :each do
        create :test_run_with_uid
      end

      it(nil, rox: { key: '13ee1c75b781' }){ should validate_uniqueness_of(:uid).case_insensitive }
    end
  end

  context "associations" do
    it(nil, rox: { key: '460cb9f79488' }){ should belong_to(:runner).class_name('User') }
    it(nil, rox: { key: 'f073cd8556c9' }){ should have_many(:results).class_name('TestResult') }
    it(nil, rox: { key: 'c61e3babd098' }){ should have_one(:runner_as_last_run).class_name('User').with_foreign_key(:last_run_id) }
    it(nil, rox: { key: '05e553d73a4d' }){ should have_many(:test_payloads) }
  end

  context "database table" do
    it(nil, rox: { key: '77e45e8ec077' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'c9568de8ccb5' }){ should have_db_column(:uid).of_type(:string).with_options(limit: 255) }
    it(nil, rox: { key: 'bea03ecfc52f' }){ should have_db_column(:group).of_type(:string).with_options(limit: 255) }
    it(nil, rox: { key: '1d6f8b2bb5bc' }){ should have_db_column(:ended_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'f69b0adabb70' }){ should have_db_column(:duration).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'cae0e328222d' }){ should have_db_column(:runner_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'bf2394ce72fa' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '1427ddb66ef6' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'a61cf96d2cfa' }){ should have_db_column(:results_count).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '30bdf4a0edf2' }){ should have_db_column(:passed_results_count).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '12b74a628d9a' }){ should have_db_column(:inactive_results_count).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'f5182f2a03e7' }){ should have_db_column(:inactive_passed_results_count).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'e77e2f48a55d' }){ should have_db_index(:uid).unique(true) }
  end
end

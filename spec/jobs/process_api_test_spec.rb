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

describe ProcessApiPayloadJob::ProcessApiTest do

  let(:user){ create :user }
  let(:project){ create :project }
  let(:project_version){ create :project_version, project: project, name: '1.0.0' }
  let(:new_category){ create :category, name: 'SoapUI' }
  let(:test_key){ create :test_key, user: user, project: project }
  let(:time_received){ Time.now }
  let(:test_run){ create :run, runner: user, ended_at: time_received }

  let :sample_data do
    HashWithIndifferentAccess.new({
      j: project.api_id,
      v: project_version.name,
      k: test_key.key,
      n: "A test",
      p: true,
      d: 500,
      f: 0,
      m: "It works!",
      c: new_category.name,
      g: [ "integration", "performance" ],
      t: [ "JIRA-12", "JIRA-34" ],
      a: {
        sql_nb_queries: "4",
        custom: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
      }
    })
  end

  let :cache do
    {
      projects: [ project ],
      project_versions: [ project_version ],
      keys: [ test_key ],
      tests: [],
      custom_values: [],
      deprecations: [],
      categories: [ new_category ],
      tags: sample_data[:g] ? sample_data[:g].collect{ |name| Tag.find_or_create_by name: name } : [],
      tickets: sample_data[:t] ? sample_data[:t].collect{ |name| Ticket.find_or_create_by name: name } : []
    }
  end

  it "should raise an error if the project API ID is unknown", rox: { key: '7fd99c1b832d' } do
    cache[:projects].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:j]))
  end

  it "should raise an error if the project version is unknown", rox: { key: '7320d15fa554' } do
    cache[:project_versions].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:v]))
  end

  it "should raise an error if the test key is unknown", rox: { key: '639a15b41e1a' } do
    cache[:keys].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:k]))
  end

  it "should raise an error if the category is unknown", rox: { key: 'a621563c5597' } do
    cache[:categories].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:c]))
  end

  it "should raise an error if a tag is unknown", rox: { key: 'cb1de9ada295' } do
    cache[:tags].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:g].first))
  end

  it "should raise an error if a ticket is unknown", rox: { key: 'f8aa513dba2f' } do
    cache[:tickets].clear
    expect{ process_test }.to raise_error(StandardError, Regexp.new(sample_data[:t].first))
  end

  context "for a new test" do

    it "should create the test", rox: { key: 'e1e22b72b04f' } do

      (processed = process_new_test).test.tap do |test|

        expect(test).to be_a_kind_of(TestInfo)
        expect(test.key).to eq(test_key)
        expect(test.author).to eq(user)
        expect(test.project).to eq(project)

        expect(test.name).to eq(sample_data[:n])
        expect(test.category).to eq(new_category)
        expect(test.passing).to be_true
        expect(test.active).to be_true

        expect(test.last_run_at).to eq(time_received)
        expect(test.last_run_duration).to eq(sample_data[:d].to_i)
        expect(test.effective_result).to eq(processed.test_result)
      end
    end

    it "should create a result for the new test", rox: { key: '6dca7bed3193' } do

      p = nil
      expect{ p = process_new_test }.to change(TestResult, :count).by(1)

      p.test_result.tap do |result|
        expect(result.runner).to eq(user)
        expect(result.test_info).to eq(p.test)
        expect(result.test_run).to eq(test_run)
        expect(result.passed).to be_true
        expect(result.active).to be_true
        expect(result.duration).to eq(sample_data[:d].to_i)
        expect(result.project_version).to eq(project_version)
        expect(result.message).to eq(sample_data[:m])
        expect(result.run_at).to eq(test_run.ended_at)

        expect(result.new_test).to be_true
        expect(result.category).to eq(new_category)
        expect(result.previous_category).to be_nil
        expect(result.previous_passed).to be_nil
        expect(result.previous_active).to be_nil
        expect(result.deprecated).to be_false
      end
    end

    it "should set whether the test and result are passing from passed", rox: { key: 'c4477e2b5377' } do
      sample_data[:p] = false
      process_new_test.tap do |p|
        expect(p.test.passing).to be_false
        expect(p.test_result.passed).to be_false
      end
    end

    it "should set whether the test and result are active from the flags", rox: { key: 'ebdf4ab41229' } do
      sample_data[:f] = TestInfo::INACTIVE
      process_new_test.tap do |p|
        expect(p.test.active).to be_false
        expect(p.test_result.active).to be_false
      end
    end

    it "should set the tags of the test", rox: { key: '9264eca0583a' } do
      p, tags = nil, cache[:tags]
      expect{ p = process_new_test }.not_to change(Tag, :count)
      p.test.tags.should match_array(tags)
    end

    it "should merge duplicate tags", rox: { key: 'f2d582008cc5' } do
      p, tags = nil, cache[:tags]
      sample_data[:g] = (sample_data[:g] * 2).shuffle
      expect{ p = process_new_test }.not_to change(Tag, :count)
      p.test.tags.should match_array(tags)
    end

    it "should merge case-insensitive duplicate tags", rox: { key: '3d2813ba331d' } do
      p, tags = nil, cache[:tags]
      sample_data[:g] = (sample_data[:g] + sample_data[:g].collect(&:capitalize)).shuffle
      expect{ p = process_new_test }.not_to change(Tag, :count)
      p.test.tags.should match_array(tags)
    end

    it "should set the tickets of the test", rox: { key: 'e7a4a9d94fe1' } do
      p, tickets = nil, cache[:tickets]
      expect{ p = process_new_test }.not_to change(Ticket, :count)
      p.test.tickets.should match_array(tickets)
    end

    it "should merge duplicate tickets", rox: { key: '16bfda0bc827' } do
      p, tickets = nil, cache[:tickets]
      sample_data[:t] = (sample_data[:t] * 2).shuffle
      expect{ p = process_new_test }.not_to change(Ticket, :count)
      p.test.tickets.should match_array(tickets)
    end

    it "should merge case-insensitive duplicate tickets", rox: { key: '5e9d3c81f217' } do
      p, tickets = nil, cache[:tickets]
      sample_data[:t] = (sample_data[:t] + sample_data[:t].collect(&:downcase)).shuffle
      expect{ p = process_new_test }.not_to change(Ticket, :count)
      p.test.tickets.should match_array(tickets)
    end

    it "should add new custom values", rox: { key: 'df41161a8092' } do
      p = nil
      expect{ p = process_new_test }.to change(TestValue, :count).by(2)
      expect(p.test.custom_values.inject({}){ |memo,v| memo[v.name] = v.contents; memo }).to eq(sample_data[:a])
    end
  end

  context "for an existing test" do

    let(:existing_category){ create :category, name: 'JUnit' }
    let(:existing_tags){ %w(integration).collect{ |name| Tag.find_or_create_by name: name } }
    let(:existing_tickets){ %w(JIRA-12).collect{ |name| Ticket.find_or_create_by name: name } }
    let(:existing_test_data){ { category: existing_category, passing: false, active: false } }
    let(:existing_test){ create :test, existing_test_data.merge(key: test_key, run_at: 1.month.ago, run_duration: 250, name: 'Old test') }
    let(:existing_values){ [ create(:test_value, test_info: existing_test, name: 'sql_nb_queries') ] }
    let(:cache){ super().merge tests: [ existing_test ], custom_values: existing_values }

    before :each do
      existing_test.tags = existing_tags
      existing_test.tickets = existing_tickets
    end

    it "should update the test", rox: { key: '6cd74abdea9a' } do

      (processed = process_existing_test).test.tap do |test|

        expect(test).to be_a_kind_of(TestInfo)
        expect(test.key).to eq(test_key)
        expect(test.author).to eq(user)
        expect(test.project).to eq(project)

        expect(test.name).to eq(sample_data[:n])
        expect(test.category).to eq(new_category)
        expect(test.passing).to be_true
        expect(test.active).to be_true

        expect(test.last_run_at).to eq(time_received)
        expect(test.last_run_duration).to eq(sample_data[:d].to_i)
        expect(test.effective_result).to eq(processed.test_result)
      end
    end

    it "should create a new result for the test", rox: { key: '23489f3c5f0c' } do

      p = nil
      expect{ p = process_existing_test }.to change(TestResult, :count).by(1)

      p.test_result.tap do |result|
        expect(result.runner).to eq(user)
        expect(result.test_info).to eq(p.test)
        expect(result.test_run).to eq(test_run)
        expect(result.passed).to be_true
        expect(result.active).to be_true
        expect(result.duration).to eq(sample_data[:d].to_i)
        expect(result.project_version).to eq(project_version)
        expect(result.message).to eq(sample_data[:m])
        expect(result.run_at).to eq(test_run.ended_at)

        expect(result.new_test).to be_false
        expect(result.category).to eq(new_category)
        expect(result.previous_category).to eq(existing_category)
        expect(result.previous_passed).to be_false
        expect(result.previous_active).to be_false
        expect(result.deprecated).to be_false
      end
    end

    it "should create a deprecated result if the test is deprecated", rox: { key: '760d40320462' } do

      existing_test.deprecation = create(:deprecation, test_info: existing_test, created_at: 1.day.ago)

      p = nil
      expect{ p = process_existing_test }.to change(TestResult, :count).by(1)

      p.test_result.tap do |result|
        expect(result.runner).to eq(user)
        expect(result.test_info).to eq(p.test)
        expect(result.test_run).to eq(test_run)
        expect(result.passed).to be_true
        expect(result.active).to be_true
        expect(result.duration).to eq(sample_data[:d].to_i)
        expect(result.project_version).to eq(project_version)
        expect(result.message).to eq(sample_data[:m])
        expect(result.run_at).to eq(test_run.ended_at)

        expect(result.new_test).to be_false
        expect(result.category).to eq(new_category)
        expect(result.previous_category).to eq(existing_category)
        expect(result.previous_passed).to be_false
        expect(result.previous_active).to be_false
        expect(result.deprecated).to be_true
      end
    end

    it "should create a deprecated result if the test was deprecated while the payload was waiting for processing", rox: { key: 'b0b29e19f8e9' } do
      cache[:deprecations] << create(:deprecation, test_info: existing_test, created_at: time_received + 1.minute)
      expect(process_existing_test.test_result.deprecated).to be_true
    end

    it "should create a non-deprecated result if the test was undeprecated while the payload was waiting for processing", rox: { key: '88cac9b42ffe' } do
      existing_test.deprecation = create(:deprecation, test_info: existing_test, created_at: 1.day.ago)
      cache[:deprecations] << create(:deprecation, deprecated: false, test_info: existing_test, created_at: time_received + 1.minute)
      expect(process_existing_test.test_result.deprecated).to be_false
    end

    context "with a previous result" do
      let(:result){ process_existing_test.test_result }

      context "that is active and successful" do
        let(:existing_test_data){ super().merge passing: true, active: true }

        it "should correctly set previous passed and previous active attributes", rox: { key: '425cf52e8d97' } do
          expect(result.previous_passed).to be_true
          expect(result.previous_active).to be_true
        end
      end

      context "that has no category" do
        let(:existing_test_data){ super().merge category: nil }

        it "should set the previous category to nil", rox: { key: '0fc984f8825d' } do
          expect(result.previous_category).to be_nil
        end
      end
    end

    it "should not change the name if not set", rox: { key: 'acc2289031aa' } do
      new_name = sample_data.delete :n
      process_existing_test.test.name.tap do |name|
        expect(name).not_to eq(new_name)
        expect(name).to eq(existing_test.name)
      end
    end

    it "should set whether the test and result are passing from passed", rox: { key: '8252b6785dad' } do
      sample_data[:p] = false
      process_existing_test.tap do |p|
        expect(p.test.passing).to be_false
        expect(p.test_result.passed).to be_false
      end
    end

    it "should set whether the test and result are active from the flags", rox: { key: '527e2ee42826' } do
      sample_data[:f] = TestInfo::INACTIVE
      process_existing_test.tap do |p|
        expect(p.test.active).to be_false
        expect(p.test_result.active).to be_false
      end
    end

    it "should not change whether the test is active if the flags are not set", rox: { key: '0f8679dba515' } do
      sample_data.delete :f
      expect(process_existing_test.test.active).to be_false
    end

    it "should not change the category if not set", rox: { key: '2dc39138d9d0' } do
      new_category = sample_data.delete :c
      process_existing_test.tap do |p|
        expect(p.test.category).not_to eq(new_category)
        expect(p.test.category).to eq(existing_test.category)
        expect(p.test_result.category).to eq(existing_test.category)
      end
    end

    it "should remove the category if set to null", rox: { key: '7817f3d84427' } do
      expect(existing_test.category).not_to be_nil
      sample_data[:c] = nil
      process_existing_test.tap do |p|
        expect(p.test.category).to be_nil
        expect(p.test_result.category).to be_nil
      end
    end

    it "should update the tags of the test", rox: { key: 'f1b7f24db0f2' } do
      p, tags = nil, cache[:tags]
      expect{ p = process_existing_test }.not_to change(Tag, :count)
      expect(p.test.tags).to match_array(tags)
    end

    it "should not change the tags if not set", rox: { key: '64f8246d3bd5' } do
      tags = existing_test.tags.dup
      expect(tags).not_to be_empty
      sample_data.delete :g
      expect(process_existing_test.test.tags).to match_array(tags)
    end

    it "should empty the tags if given an empty array", rox: { key: '319e8d430e02' } do
      expect(existing_test.tags).not_to be_empty
      sample_data[:g] = []
      expect(process_existing_test.test.tags).to be_empty
    end

    it "should merge duplicate tags", rox: { key: '261c76b19c7a' } do
      p, tags = nil, cache[:tags]
      sample_data[:g] = (sample_data[:g] * 2).shuffle
      expect{ p = process_existing_test }.not_to change(Tag, :count)
      p.test.tags.should match_array(tags)
    end

    it "should merge case-insensitive duplicate tags", rox: { key: '42eac83058cb' } do
      p, tags = nil, cache[:tags]
      sample_data[:g] = (sample_data[:g] + sample_data[:g].collect(&:capitalize)).shuffle
      expect{ p = process_existing_test }.not_to change(Tag, :count)
      p.test.tags.should match_array(tags)
    end

    it "should update the tickets of the test", rox: { key: '40bb4a98a77f' } do
      p, tickets = nil, cache[:tickets]
      expect{ p = process_existing_test }.not_to change(Ticket, :count)
      expect(p.test.tickets).to match_array(tickets)
    end

    it "should not change the tickets if not set", rox: { key: 'cf513fba9b09' } do
      tickets = existing_test.tickets.dup
      expect(tickets).not_to be_empty
      sample_data.delete :t
      expect(process_existing_test.test.tickets).to match_array(tickets)
    end

    it "should empty the tickets if given an empty array", rox: { key: 'f30d148cd860' } do
      expect(existing_test.tickets).not_to be_empty
      sample_data[:t] = []
      expect(process_existing_test.test.tickets).to be_empty
    end

    it "should merge duplicate tickets", rox: { key: 'a43d321f2bea' } do
      p, tickets = nil, cache[:tickets]
      sample_data[:t] = (sample_data[:t] * 2).shuffle
      expect{ p = process_existing_test }.not_to change(Ticket, :count)
      p.test.tickets.should match_array(tickets)
    end

    it "should merge case-insensitive duplicate tickets", rox: { key: '0e5e6b8bb698' } do
      p, tickets = nil, cache[:tickets]
      sample_data[:t] = (sample_data[:t] + sample_data[:t].collect(&:downcase)).shuffle
      expect{ p = process_existing_test }.not_to change(Ticket, :count)
      p.test.tickets.should match_array(tickets)
    end

    it "should add new custom values and modify existing ones", rox: { key: '077f7c1e5701' } do
      p, custom_values = nil, cache[:custom_values]
      expect{ p = process_existing_test }.to change(TestValue, :count).by(1)
      expect(p.test.custom_values.inject({}){ |memo,v| memo[v.name] = v.contents; memo }).to eq(sample_data[:a].stringify_keys)
    end
  end

  private

  def process_new_test *args
    test = nil
    expect{ test = process_test *args }.to change(TestInfo, :count).by(1)
    test
  end

  def process_existing_test *args
    test = nil
    expect{ test = process_test *args }.not_to change(TestInfo, :count)
    test
  end

  def process_test data = sample_data, run = test_run, cache = cache
    ProcessApiPayloadJob::ProcessApiTest.new data, run, cache
  end

  def category name
    Category.find_by_name name
  end

  def tag name
    Tag.find_by_name name
  end

  def ticket name
    Ticket.find_by_name name
  end
end

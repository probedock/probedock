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

describe "API sample payload", rox: { tags: :integration } do

  def users
    @users ||= [ create(:user), create(:other_user) ]
  end

  def projects
    @projects ||= Array.new(2){ |i| create :project }
  end

  def test_keys
    return @keys if @keys
    key_projects = [ projects[0], projects[0], projects[1], projects[0], projects[1] ]
    @keys = Array.new(5){ |i| create :test_key, user: users[i % 2], project: key_projects.shift }
  end

  def lorem_ipsum
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  end

  def first_payload
    @payload1 ||= HashWithIndifferentAccess.new({
      u: "f47ac10b-58cc",
      g: "nightly",
      d: 180000,
      r: [
        {
          j: projects[0].api_id,
          v: "1.0.0",
          t: [
            {
              k: test_keys[0].key, # new test, project 0
              n: "A test",
              p: true,
              d: 500,
              f: 1,
              c: "junit",
              g: [ "integration", "performance" ],
              t: [ "#12", "#34" ],
              a: {
                sql_nb_queries: "4",
                custom: lorem_ipsum
              }
            },
            {
              k: test_keys[1].key, # new test, project 0
              n: "Test 2",
              p: true,
              d: 5000,
              f: 0,
              m: "Foo",
              c: "selenium",
              g: [ "automated" ],
              t: [ "#56" ],
              a: {
                custom: lorem_ipsum
              }
            }
          ]
        },
        {
          j: projects[1].api_id,
          v: "1.0.2",
          t: [
            {
              k: test_keys[2].key, # new test, project 1
              n: "Test 3",
              p: false,
              d: 300,
              m: "Didn't work.",
              c: "junit",
              g: [ "unit", "performance", "slow" ],
              t: [ "#78" ]
            }
          ]
        }
      ]
    })
  end

  def second_payload
    @payload2 ||= HashWithIndifferentAccess.new({
      u: "f47ac10b-58cc",
      g: "nightly",
      d: 400000,
      r: [
        {
          j: projects[0].api_id,
          v: "1.0.0",
          t: [
            {
              k: test_keys[3].key,   # existing test, project 0
              n: "Test 4",
              p: true,               # failed -> passed
              d: 75,                 # 50 -> 75
              f: 0,                  # inactive -> active
              c: "soapui",           # nil -> soapui
              g: [],                 # -integration
              t: [ "#12" ],          # +#12
              a: {                   # +custom
                custom: lorem_ipsum
              }
            }
          ]
        }
      ]
    })
  end

  def third_payload
    @payload3 ||= HashWithIndifferentAccess.new({
      d: 3600000,
      r: [
        {
          j: projects[0].api_id,
          v: "1.0.0",
          t: [
            {
              k: test_keys[0].key,   # existing test, project 0
              n: "Test 1",           # A test -> Test 1
              p: false,              # passed -> failed
              d: 750,                # 500 -> 750
              f: 0,                  # inactive -> active
              m: "fubar",            # nil -> "fubar"
              c: "soapui",           # junit -> soapui
              g: [ "integration", "slow" ], # +slow -performance
              t: [ "#12", "#34" ],
              a: {
                sql_nb_queries: "5" # 4 -> 5, -custom
              }
            }
          ]
        },
        {
          j: projects[1].api_id,
          v: "1.0.3",                # 1.0.2 -> 1.0.3
          t: [
            { # cached test with no changes
              k: test_keys[2].key,   # existing test, project 1
              p: true,               # failed -> passed
              d: 200                 # 300 -> 200
            },
            {
              k: test_keys[4].key,   # new test, project 1
              n: "Test 5",
              p: true,
              d: 0
            }
          ]
        }
      ]
    })
  end

  it "should be queued for processing", rox: { key: '8768a7792cf0' } do
    ResqueSpec.reset!

    # Note: the third payload cannot be posted at this stage.
    # The first payload must have been processed first.
    payloads = [ first_payload, second_payload ].collect{ |p| MultiJson.dump p }
    payloads.each{ |p| post_api_payload p, users[0] }

    ProcessApiPayloadJob.should have_queued(MultiJson.load(payloads[0]), users[0].id, kind_of(String)).in(:api)
    ProcessApiPayloadJob.should have_queued(MultiJson.load(payloads[1]), users[0].id, kind_of(String)).in(:api)
    ProcessApiPayloadJob.should have_queue_size_of(2).in(:api)
  end

  context "when processed" do

    def timezone
      'Bern'
    end

    def posting_day_in_timezone
      Time.use_zone(timezone){ t = Time.zone.at(@before_posting_payloads.to_time); Time.zone.local t.year, t.month, t.day }
    end

    before :all do

      ResqueSpec.reset!

      existing_version = create :project_version, project: test_keys[3].project, name: '0.1.0'
      existing_test = create :test, key: test_keys[3], passing: false, active: false, run_at: 1.month.ago, run_duration: 50, project_version: existing_version
      existing_test.tags << Tag.find_or_create_by(name: 'integration')
      test_keys[3].update_attribute :free, false

      @before_posting_payloads = Time.now

      expect(TestRun.count).to eq(1)
      expect(ProjectVersion.count).to eq(1)
      expect(TestInfo.count).to eq(1)
      expect(TestResult.count).to eq(1)
      expect(Category.count).to eq(0)
      expect(Tag.count).to eq(1)
      expect(Ticket.count).to eq(0)
      expect(TestValue.count).to eq(0)
      expect(TestCounter.count).to eq(0)
      expect(test_keys.each(&:reload).collect(&:free?)).to eq([ true, true, true, false, true ])

      with_resque do
        [ first_payload, second_payload, third_payload ].each_with_index do |p,i|
          post_api_payload MultiJson.dump(p), users[i < 2 ? 0 : 1]
        end
      end
    end

    before(:each){ ResqueSpec.reset! }

    after(:all){ DatabaseCleaner.clean }

    it "should create the correct number of test runs", rox: { key: '5d78f9cbaaf5' } do
      expect(TestRun.count).to eq(3)
    end

    it "should create the correct number of project versions", rox: { key: '44b2f0c1e728' } do
      expect(ProjectVersion.count).to eq(4)
    end

    it "should create the correct number of tests", rox: { key: 'c91c6fafc663' } do
      expect(TestInfo.count).to eq(5)
    end

    it "should create the correct number of test results", rox: { key: '6d1e906787fe' } do
      expect(TestResult.count).to eq(8)
    end

    it "should create the correct number of categories", rox: { key: 'e176416288a3' } do
      expect(Category.count).to eq(3)
    end

    it "should create the correct number of tags", rox: { key: '1f598d7e3d2c' } do
      expect(Tag.count).to eq(5)
    end

    it "should create the correct number of tickets", rox: { key: 'b63039c9b203' } do
      expect(Ticket.count).to eq(4)
    end

    it "should create the correct number of test values", rox: { key: 'da2fb254d1e2' } do
      expect(TestValue.count).to eq(4)
    end

    it "should create the correct number of test counters", rox: { key: '4c3172646fc3' } do
      expect(TestCounter.count).to eq(27)
    end

    it "should correctly link tests to categories", rox: { key: '4be417cdc59c' } do
      expect(category('junit').test_infos.collect(&:key)).to match_array([ test_keys[2] ])
      expect(category('soapui').test_infos.collect(&:key)).to match_array([ test_keys[0], test_keys[3] ])
      expect(category('selenium').test_infos.collect(&:key)).to match_array([ test_keys[1] ])
    end

    it "should correctly link tests to tags", rox: { key: 'e63d2477177e' } do
      expect(tag('unit').test_infos.collect(&:key)).to match_array([ test_keys[2] ])
      expect(tag('integration').test_infos.collect(&:key)).to match_array([ test_keys[0] ])
      expect(tag('performance').test_infos.collect(&:key)).to match_array([ test_keys[2] ])
      expect(tag('automated').test_infos.collect(&:key)).to match_array([ test_keys[1] ])
      expect(tag('slow').test_infos.collect(&:key)).to match_array([ test_keys[0], test_keys[2] ])
    end

    it "should correctly link tests to tickets", rox: { key: '2ded4a9d395b' } do
      expect(ticket('#12').test_infos.collect(&:key)).to match_array([ test_keys[0], test_keys[3] ])
      expect(ticket('#34').test_infos.collect(&:key)).to match_array([ test_keys[0] ])
      expect(ticket('#56').test_infos.collect(&:key)).to match_array([ test_keys[1] ])
      expect(ticket('#78').test_infos.collect(&:key)).to match_array([ test_keys[2] ])
    end

    it "should correctly link tests to users", rox: { key: 'e885bcd54aa3' } do
      expect(users[0].test_infos.collect(&:key)).to match_array([ test_keys[0], test_keys[2], test_keys[4] ])
      expect(users[1].test_infos.collect(&:key)).to match_array([ test_keys[1], test_keys[3] ])
    end

    it "should correctly mark all keys as used", rox: { key: '04b81846c673' } do
      expect(test_keys.each(&:reload).any?(&:free?)).to be_false
    end

    it "should correctly create test run 1", rox: { key: '4f82f5889ab0' } do

      # The first payload posted above is the second one in the database
      # because there was one created earlier in before(:all).
      run = TestRun.order('id ASC').limit(1).offset(1).first

      expect(run).to be_present
      expect(run.runner).to eq(users[0])
      expect(run.uid).to eq(first_payload[:u])
      expect(run.group).to eq(first_payload[:g])
      expect(run.duration).to eq(second_payload[:d])
      expect(run.ended_at).to be >= @before_posting_payloads
      expect(run.results).to have(4).items
      expect(run.results_count).to eq(4)
      expect(run.passed_results_count).to eq(3)
      expect(run.inactive_results_count).to eq(1)
      expect(run.inactive_passed_results_count).to eq(1)
    end

    it "should correctly create test run 2", rox: { key: 'b616d73d26d0' } do

      # The second payload posted above is the third one in the database
      # because there was one created earlier in before(:all).
      run = TestRun.order('id ASC').limit(1).offset(2).first

      expect(run).to be_present
      expect(run.runner).to eq(users[1])
      expect(run.uid).to be_nil
      expect(run.group).to be_nil
      expect(run.duration).to eq(third_payload[:d])
      expect(run.ended_at).to be >= @before_posting_payloads
      expect(run.results).to have(3).items
      expect(run.results_count).to eq(3)
      expect(run.passed_results_count).to eq(2)
      expect(run.inactive_results_count).to eq(0)
      expect(run.inactive_passed_results_count).to eq(0)
    end

    it "should correctly update test 1", rox: { key: 'f0648503ac56' } do

      key = test_keys[0]
      test = key.test_info

      expect(test.name).to eq("Test 1")
      expect(test.project).to eq(key.project)
      expect(test.author).to eq(key.user)
      expect(test.passing).to be_false
      expect(test.active).to be_true
      expect(test.category).to eq(category("soapui"))
      expect(test.tags).to match_array([ tag(:integration), tag(:slow) ])
      expect(test.tickets).to match_array([ ticket('#12'), ticket('#34') ])
      expect(test.custom_values.inject({}){ |memo,v| memo[v.name] = v.contents; memo }).to eq({ 'sql_nb_queries' => '5', 'custom' => lorem_ipsum })
      expect(test.last_run_at).to be >= @before_posting_payloads
      expect(test.last_run_duration).to eq(750)

      results = test.results.order('created_at ASC').to_a
      expect(results).to have(2).items

      result = results.first
      expect(result.project_version).to eq(project_version(key.project, "1.0.0"))
      expect(result.passed).to be_true
      expect(result.active).to be_false
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(500)
      expect(result.message).to be_nil
      expect(result.runner).to eq(users[0])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(1).first)
      expect(result.new_test).to be_true
      expect(result.category).to eq(category("junit"))
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_nil
      expect(result.previous_active).to be_nil

      result = results.last
      expect(result.project_version).to eq(project_version(key.project, "1.0.0"))
      expect(result.passed).to be_false
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(750)
      expect(result.message).to eq("fubar")
      expect(result.runner).to eq(users[1])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(2).first)
      expect(result.new_test).to be_false
      expect(result.category).to eq(category("soapui"))
      expect(result.previous_category).to eq(category("junit"))
      expect(result.previous_passed).to be_true
      expect(result.previous_active).to be_false
    end

    it "should correctly update test 2", rox: { key: '1d7ebcd9419e' } do

      key = test_keys[1]
      test = key.test_info

      expect(test.name).to eq("Test 2")
      expect(test.project).to eq(key.project)
      expect(test.author).to eq(key.user)
      expect(test.passing).to be_true
      expect(test.active).to be_true
      expect(test.category).to eq(category("selenium"))
      expect(test.tags).to match_array([ tag(:automated) ])
      expect(test.tickets).to match_array([ ticket('#56') ])
      expect(test.custom_values.inject({}){ |memo,v| memo[v.name] = v.contents; memo }).to eq({ 'custom' => lorem_ipsum })
      expect(test.last_run_at).to be >= @before_posting_payloads
      expect(test.last_run_duration).to eq(5000)

      results = test.results.to_a
      expect(results).to have(1).item

      result = results.first
      expect(result.project_version).to eq(project_version(key.project, "1.0.0"))
      expect(result.passed).to be_true
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(5000)
      expect(result.message).to eq("Foo")
      expect(result.runner).to eq(users[0])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(1).first)
      expect(result.new_test).to be_true
      expect(result.category).to eq(category("selenium"))
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_nil
      expect(result.previous_active).to be_nil
    end

    it "should correctly update test 3", rox: { key: '637b633ae087' } do

      key = test_keys[2]
      test = key.test_info

      expect(test.name).to eq("Test 3")
      expect(test.project).to eq(key.project)
      expect(test.author).to eq(key.user)
      expect(test.passing).to be_true
      expect(test.active).to be_true
      expect(test.category).to eq(category("junit"))
      expect(test.tags).to match_array([ tag(:unit), tag(:performance), tag(:slow) ])
      expect(test.tickets).to match_array([ ticket('#78') ])
      expect(test.custom_values).to be_empty
      expect(test.last_run_at).to be >= @before_posting_payloads
      expect(test.last_run_duration).to eq(200)

      results = test.results.to_a
      expect(results).to have(2).items

      result = results.first
      expect(result.project_version).to eq(project_version(key.project, "1.0.2"))
      expect(result.passed).to be_false
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(300)
      expect(result.message).to eq("Didn't work.")
      expect(result.runner).to eq(users[0])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(1).first)
      expect(result.new_test).to be_true
      expect(result.category).to eq(category("junit"))
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_nil
      expect(result.previous_active).to be_nil

      result = results.last
      expect(result.project_version).to eq(project_version(key.project, "1.0.3"))
      expect(result.passed).to be_true
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(200)
      expect(result.message).to be_nil
      expect(result.runner).to eq(users[1])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(2).first)
      expect(result.new_test).to be_false
      expect(result.category).to eq(category("junit"))
      expect(result.previous_category).to eq(category("junit"))
      expect(result.previous_passed).to be_false
      expect(result.previous_active).to be_true
    end

    it "should correctly update test 4", rox: { key: 'ec54b3e2dd8b' } do

      key = test_keys[3]
      test = key.test_info

      expect(test.name).to eq("Test 4")
      expect(test.project).to eq(key.project)
      expect(test.author).to eq(key.user)
      expect(test.passing).to be_true
      expect(test.active).to be_true
      expect(test.category).to eq(category("soapui"))
      expect(test.tags).to be_empty
      expect(test.tickets).to match_array([ ticket('#12') ])
      expect(test.custom_values.inject({}){ |memo,v| memo[v.name] = v.contents; memo }).to eq({ 'custom' => lorem_ipsum })
      expect(test.last_run_at).to be >= @before_posting_payloads
      expect(test.last_run_duration).to eq(75)

      results = test.results.to_a
      expect(results).to have(2).items

      result = results.first # already existed before submitting payloads
      expect(result.passed).to be_false
      expect(result.active).to be_false
      expect(result.run_at).to be < @before_posting_payloads
      expect(result.duration).to eq(50)
      expect(result.runner).to eq(users[1])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(0).first)
      expect(result.new_test).to be_true
      expect(result.category).to be_nil
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_nil
      expect(result.previous_active).to be_nil

      result = results.last
      expect(result.project_version).to eq(project_version(key.project, "1.0.0"))
      expect(result.passed).to be_true
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(75)
      expect(result.message).to be_nil
      expect(result.runner).to eq(users[0])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(1).first)
      expect(result.new_test).to be_false
      expect(result.category).to eq(category("soapui"))
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_false
      expect(result.previous_active).to be_false
    end

    it "should correctly update test 5", rox: { key: '165123760e72' } do

      key = test_keys[4]
      test = key.test_info

      expect(test.name).to eq("Test 5")
      expect(test.project).to eq(key.project)
      expect(test.author).to eq(key.user)
      expect(test.passing).to be_true
      expect(test.active).to be_true
      expect(test.category).to be_nil
      expect(test.tags).to be_empty
      expect(test.tickets).to be_empty
      expect(test.custom_values).to be_empty
      expect(test.last_run_at).to be >= @before_posting_payloads
      expect(test.last_run_duration).to eq(0)

      results = test.results.to_a
      expect(results).to have(1).item

      result = results.first
      expect(result.project_version).to eq(project_version(key.project, "1.0.3"))
      expect(result.passed).to be_true
      expect(result.active).to be_true
      expect(result.run_at).to be >= @before_posting_payloads
      expect(result.duration).to eq(0)
      expect(result.message).to be_nil
      expect(result.runner).to eq(users[1])
      expect(result.test_run).to eq(TestRun.order('id ASC').limit(1).offset(2).first)
      expect(result.new_test).to be_true
      expect(result.category).to be_nil
      expect(result.previous_category).to be_nil
      expect(result.previous_passed).to be_nil
      expect(result.previous_active).to be_nil
    end

    it "should correctly count tests", rox: { key: '2052888f6d0f' } do

      # global (3)
      expect_counter mask: 0, written: 4, run: 7
      expect_counter mask: 1, user_id: users[0], written: 3, run: 4
      expect_counter mask: 1, user_id: users[1], written: 1, run: 3

      # by user (4)
      expect_counter mask: 2, category_id: nil, written: 0, run: 1
      expect_counter mask: 2, category_id: category('junit'), written: 1, run: 3
      expect_counter mask: 2, category_id: category('selenium'), written: 1, run: 1
      expect_counter mask: 2, category_id: category('soapui'), written: 2, run: 2

      # by category and user (8)
      expect_counter mask: 3, user_id: users[0], category_id: nil, written: 1, run: 0
      expect_counter mask: 3, user_id: users[0], category_id: category('junit'), written: 1, run: 2
      expect_counter mask: 3, user_id: users[0], category_id: category('selenium'), written: 0, run: 1
      expect_counter mask: 3, user_id: users[0], category_id: category('soapui'), written: 1, run: 1
      expect_counter mask: 3, user_id: users[1], category_id: nil, written: -1, run: 1
      expect_counter mask: 3, user_id: users[1], category_id: category('junit'), written: 0, run: 1
      expect_counter mask: 3, user_id: users[1], category_id: category('selenium'), written: 1, run: 0
      expect_counter mask: 3, user_id: users[1], category_id: category('soapui'), written: 1, run: 1

      # by project (2)
      expect_counter mask: 4, project_id: projects[0], written: 2, run: 4
      expect_counter mask: 4, project_id: projects[1], written: 2, run: 3

      # by project and user (4)
      expect_counter mask: 5, project_id: projects[0], user_id: users[0], written: 1, run: 3
      expect_counter mask: 5, project_id: projects[0], user_id: users[1], written: 1, run: 1
      expect_counter mask: 5, project_id: projects[1], user_id: users[0], written: 2, run: 1
      expect_counter mask: 5, project_id: projects[1], user_id: users[1], written: 0, run: 2

      # by project and category (6)
      expect_counter mask: 6, project_id: projects[0], category_id: nil, written: -1, run: 0
      expect_counter mask: 6, project_id: projects[0], category_id: category('junit'), written: 0, run: 1
      expect_counter mask: 6, project_id: projects[0], category_id: category('selenium'), written: 1, run: 1
      expect_counter mask: 6, project_id: projects[0], category_id: category('soapui'), written: 2, run: 2
      expect_counter mask: 6, project_id: projects[1], category_id: nil, written: 1, run: 1
      expect_counter mask: 6, project_id: projects[1], category_id: category('junit'), written: 1, run: 2
      expect_counter mask: 6, project_id: projects[1], category_id: category('selenium'), written: 0, run: 0 # no counter
      expect_counter mask: 6, project_id: projects[1], category_id: category('soapui'), written: 0, run: 0 # no counter
    end
  end

  private

  def expect_counter options = {}
    updates = %w(written run).inject({}){ |memo,k| memo[k.to_sym] = options.delete(k.to_sym).to_i; memo }
    TestCounter.where({ timezone: timezone, timestamp: posting_day_in_timezone }.merge(options)).first.tap do |counter|
      if updates.values.all?{ |v| v == 0 }
        expect(counter).to be_nil
      else
        expect(counter).not_to be_nil
        expect(counter.written_counter).to eq(updates[:written])
        expect(counter.run_counter).to eq(updates[:run])
      end
    end
  end

  def project_version project, name
    ProjectVersion.where(project_id: project.id, name: name).first
  end

  def category name
    Category.find_by_name name.to_s
  end

  def tag name
    Tag.find_by_name name.to_s
  end

  def ticket name
    Ticket.find_by_name name.to_s
  end
end

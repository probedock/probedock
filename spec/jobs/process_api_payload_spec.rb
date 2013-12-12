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
require 'spec_helper'

describe ProcessApiPayload do

  let(:user){ create :user }
  let(:time_received){ Time.now }
  let(:time_received_string){ time_received.to_r.to_s }
  let(:processed_test_run){ double }
  let(:projects){ Array.new(2){ |i| create :project } }
  let(:test_keys){ Array.new(3){ |i| create :test_key, user: user, project: i < 2 ? projects[0] : projects[1] } }
  let(:sample_payload) do
    HashWithIndifferentAccess.new({
      u: "f47ac10b-58cc",
      g: "nightly",
      d: 3600000,
      r: [
        {
          j: projects[0].api_id,
          v: "1.0.2",
          t: [
            {
              k: test_keys[0].key,
              n: "Test 1",
              p: true,
              d: 500,
              f: 1,
              m: "It works!",
              c: "SoapUI",
              g: [ "integration", "performance" ],
              t: [ "#12", "#34" ],
              a: {
                sql_nb_queries: "4",
                custom: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
              }
            },
            {
              k: test_keys[1].key,
              n: "Test 2",
              p: false,
              d: 5000,
              f: 0,
              m: "Foo",
              c: "Selenium",
              g: [ "automated" ],
              t: [ "#56" ],
              a: {
                custom: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
              }
            }
          ]
        },
        {
          j: projects[1].api_id,
          v: "1.0.3",
          t: [
            {
              k: test_keys[2].key,
              n: "Test 3",
              p: true,
              d: 300,
              m: "It also works!",
              c: "JUnit",
              g: [ "unit", "captcha" ],
              t: [ "#78" ]
            }
          ]
        }
      ]
    })
  end

  before :each do
    ProcessApiTestRun.stub(:new){ |*args| processed_test_run }
    ROXCenter::Application.events.stub :fire
  end

  it "should process the test run in the payload", rox: { key: 'f27fdc182dad' } do
    ProcessApiTestRun.should_receive(:new).exactly(1).times.with(HashWithIndifferentAccess.new(sample_payload), user, time_received, kind_of(Hash))
    expect(process_payload.processed_test_run).to eq(processed_test_run)
  end

  it "should log the number of processed tests", rox: { key: '04e14ea5cd27' } do
    Rails.logger.should_receive(:info).ordered.twice
    Rails.logger.should_receive(:info).ordered.with do |*args|
      args.first.should match(/#{sample_payload[:r].inject(0){ |memo,r| memo + r[:t].length }} test results/)
    end
    process_payload
  end

  it "should accept a payload with string keys", rox: { key: '4e162def25ce' } do
    expect(process_payload(sample_payload.stringify_keys).processed_test_run).to eq(processed_test_run)
  end

  it "should load the user who submitted the payload", rox: { key: '5ffde54ccbbf' } do
    expect(process_payload.user).to eq(user)
  end

  it "should parse the time at which the payload was received", rox: { key: 'a56bd35cd793' } do
    expect(process_payload.time_received).to eq(time_received)
  end

  it "should trigger an api:payload event on the application", rox: { key: '9fc739a396b9' } do
    ROXCenter::Application.events.should_receive(:fire).with 'api:payload', kind_of(ProcessApiPayload)
    process_payload
  end

  it "should mark free keys as used", rox: { key: '874aab561f85' } do
    expect(test_keys.any?(&:free?)).to be_true
    process_payload
    expect(test_keys.each(&:reload).none?(&:free)).to be_true
  end

  context "cache" do

    it "should fetch all test keys", rox: { key: '22b307f18606' } do
      expect(process_payload.cache[:keys]).to match_array(test_keys)
    end

    it "should fetch all projects", rox: { key: 'fac2d427f0e3' } do
      expect(process_payload.cache[:projects]).to match_array(projects)
    end

    it "should fetch existing project versions and create new ones", rox: { key: '852b66c9ee22' } do
      create :project_version, project: projects[0], name: '1.0.2'
      versions = nil
      expect{ versions = process_payload.cache[:project_versions] }.to change(ProjectVersion, :count).by(1)
      expect(versions.collect{ |v| "#{v.project.name} v#{v.name}" }).to match_array([ "#{projects[0].name} v1.0.2", "#{projects[1].name} v1.0.3" ])
    end

    it "should merge case-insensitive duplicate versions", rox: { key: '7f3a2e3d26ff' } do
      sample_payload[:r][0][:v] = '1.0.2-alpha'
      create :project_version, project: projects[0], name: '1.0.2-ALPHA'
      versions = nil
      expect{ versions = process_payload.cache[:project_versions] }.to change(ProjectVersion, :count).by(1)
      expect(versions.collect{ |v| "#{v.project.name} v#{v.name}" }).to match_array([ "#{projects[0].name} v1.0.2-ALPHA", "#{projects[1].name} v1.0.3" ])
    end

    it "should fetch all tests", rox: { key: '2fb68542ef4a' } do
      tests = Array.new(2){ |i| create :test, key: test_keys[i] }
      expect(process_payload.cache[:tests]).to match_array(tests)
    end

    it "should fetch all test deprecations since the time the payload was received", rox: { key: '130423f4afaf' } do

      deprecations = []

      test1 = create :test, key: test_keys[0]
      deprecations << create(:deprecation, test_info: test1, created_at: 5.minutes.from_now)

      test2 = create :test, key: test_keys[1], run_at: 3.days.ago, deprecated_at: 2.days.ago
      create(:deprecation, deprecated: false, test_info: test2, created_at: 1.hour.ago)
      deprecations << create(:deprecation, test_info: test2, created_at: 10.minutes.from_now)
      deprecations << create(:deprecation, deprecated: false, test_info: test2, created_at: 12.minutes.from_now)

      test3 = create :test, key: test_keys[2], run_at: 5.days.ago, deprecated_at: 4.days.ago

      expect(process_payload.cache[:deprecations]).to match_array(deprecations)
    end

    it "should fetch the test run by UID if it already exists", rox: { key: '814f932a3fc7' } do
      run = create :run_with_uid, runner: user
      test = create :test, key: create(:test_key, user: user, project: projects[0]), test_run: run
      sample_payload[:u] = run.uid
      expect(process_payload.cache[:run]).to eq(run)
    end

    it "should fetch existing categories and create new ones", rox: { key: 'e498fa89a412' } do
      create :category, name: 'SoapUI'
      categories = nil
      expect{ categories = process_payload.cache[:categories] }.to change(Category, :count).by(2)
      expect(categories.collect(&:name)).to match_array([ 'SoapUI', 'JUnit', 'Selenium' ])
    end

    it "should merge case-insensitive duplicate categories", rox: { key: '192fef27f139' } do
      sample_payload[:r][0][:t][0][:c] = 'foo'
      sample_payload[:r][0][:t][1][:c] = 'Foo'
      categories = nil
      expect{ categories = process_payload.cache[:categories] }.to change(Category, :count).by(2)
      expect(categories.collect(&:name)).to match_array([ 'foo', 'JUnit' ])
    end

    it "should fetch existing tags and create new ones", rox: { key: '63d035a205d7' } do
      %w(unit automated).each{ |name| Tag.find_or_create_by_name name }
      tags = nil
      expect{ tags = process_payload.cache[:tags] }.to change(Tag, :count).by(3)
      expect(tags.collect(&:name)).to match_array(sample_payload[:r].inject([]){ |memo,r| memo + r[:t].inject([]){ |memo,t| memo + (t[:g] || []) } })
    end

    it "should merge case-insensitive duplicate tags", rox: { key: 'df8050c531a6' } do
      sample_payload[:r][0][:t][0][:g] = sample_payload[:r][0][:t][0][:g] + [ 'foo' ]
      sample_payload[:r][0][:t][1][:g] = sample_payload[:r][0][:t][1][:g] + [ 'Foo' ]
      tags = nil
      lambda{ tags = process_payload.cache[:tags] }.should change(Tag, :count).by(6)
      expect(tags.collect(&:name)).to match_array(sample_payload[:r].inject([]){ |memo,r| memo + r[:t].inject([]){ |memo,t| memo + (t[:g] || []) } }.uniq(&:downcase))
    end

    it "should fetch existing tickets and create new ones", rox: { key: '348da45fdfbc' } do
      %w(#12 #78).each{ |name| Ticket.find_or_create_by_name name }
      tickets = nil
      lambda{ tickets = process_payload.cache[:tickets] }.should change(Ticket, :count).by(2)
      expect(tickets.collect(&:name)).to match_array(sample_payload[:r].inject([]){ |memo,r| memo + r[:t].inject([]){ |memo,t| memo + (t[:t] || []) } })
    end

    it "should merge case-insensitive duplicate tickets", rox: { key: '64dae944be76' } do
      sample_payload[:r][0][:t][0][:t] = sample_payload[:r][0][:t][0][:t] + [ 'JIRA-dup' ]
      sample_payload[:r][0][:t][1][:g] = sample_payload[:r][0][:t][1][:g] + [ 'JIRA-DUP' ]
      tickets = nil
      lambda{ tickets = process_payload.cache[:tickets] }.should change(Ticket, :count).by(5)
      expect(tickets.collect(&:name)).to match_array(sample_payload[:r].inject([]){ |memo,r| memo + r[:t].inject([]){ |memo,t| memo + (t[:t] || []) } }.uniq(&:downcase))
    end

    it "should fetch existing test values", rox: { key: '9f2ec3b8ff68' } do
      test = create :test, key: test_keys[0]
      existing_values = [ create(:test_value, name: 'custom', test_info: test) ]
      values = nil
      expect{ values = process_payload.cache[:custom_values] }.not_to change(TestValue, :count)
      expect(values).to match_array(existing_values)
    end
  end

  private

  def process_payload data = sample_payload, user_id = user.id, time_received = time_received_string
    ProcessApiPayload.new data, user_id, time_received
  end
end

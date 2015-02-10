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

describe TestInfo, probe_dock: { tags: :unit } do

  describe "#breaker" do

    it "should return nil for new tests", probe_dock: { key: '1a5aee484d1f' } do
      expect(TestInfo.new.breaker).to be_nil
    end

    it "should return nil for passing tests", probe_dock: { key: '607f941fbdd2' } do
      expect(create(:test).breaker).to be_nil
    end

    it "should return the runner of the effective result for broken tests", probe_dock: { key: 'd63d2e63d920' } do
      test = create :test, passing: false
      expect(test.breaker).to eq(test.effective_result.runner)
    end
  end

  describe "#to_param" do

    it "should return the project api id and test key value joined with a hyphen", probe_dock: { key: '27893c41b7af' } do
      test = create :test
      expect(test.to_param).to eq("#{test.project.api_id}-#{test.key.key}")
    end
  end

  describe "#find_by_project_and_key" do

    it "should find a test by project and key", probe_dock: { key: 'dffde25a0e26' } do
      test = create :test
      expect(TestInfo.find_by_project_and_key("#{test.project.api_id}-#{test.key.key}").first).to eq(test)
    end

    it "should not find an unknown test", probe_dock: { key: 'f74cad482f9e' } do
      expect(TestInfo.find_by_project_and_key("123456789012-987654321098").first).to be_nil
    end

    it "should not find a test with an invalid param", probe_dock: { key: '72269073bf73' } do
      expect(TestInfo.find_by_project_and_key("foo")).to be_nil
    end
  end

  describe "#find_by_project_and_key!" do

    it "should find a test by project and key", probe_dock: { key: '2b14c1da77ba' } do
      test = create :test
      expect(TestInfo.find_by_project_and_key!("#{test.project.api_id}-#{test.key.key}").first).to eq(test)
    end

    it "should not find an unknown test", probe_dock: { key: 'f72ee92b8162' } do
      expect{ TestInfo.find_by_project_and_key!("123456789012-987654321098").first! }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not find a test with an invalid param", probe_dock: { key: '1f39e71a7d15' } do
      expect{ TestInfo.find_by_project_and_key! "foo" }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#deprecated?" do

    it "should return true if the test is linked to a deprecation", probe_dock: { key: '28ef7683957f' } do
      user = create :user
      expect(create(:test, key: create(:key, user: user)).deprecated?).to be(false)
      expect(create(:test, key: create(:key, user: user), deprecated_at: 10.days.ago).deprecated?).to be(true)
    end
  end

  describe "lookup" do
    let(:user){ create :user }
    let! :tests do
      [
        create(:test, key: create(:key, user: user)),
        create(:test, key: create(:key, user: user), run_at: 3.days.ago),
        create(:test, key: create(:key, user: user), passing: false),
        create(:test, key: create(:key, user: user), active: false, deprecated_at: 4.days.ago, run_at: 6.days.ago),
        create(:test, key: create(:key, user: user), passing: false, active: false, run_at: 1.day.ago),
        create(:test, key: create(:key, user: user), run_at: 5.days.ago),
        create(:test, key: create(:key, user: user), active: false, deprecated_at: 3.days.ago),
        create(:test, key: create(:key, user: user), run_at: 7.days.ago),
        create(:test, key: create(:key, user: user), passing: false, deprecated_at: 3.days.ago)
      ]
    end

    describe ".standard" do

      it "should return all tests that are not deprecated", probe_dock: { key: 'f83868e2b6ee' } do
        expect(described_class.standard.to_a).to match_array([ 0, 1, 2, 4, 5, 7 ].collect{ |i| tests[i] })
      end
    end

    describe ".outdated" do

      it "should return standard tests that have not been run since the outdated delay", probe_dock: { key: 'f72aff790693' } do
        allow(Settings).to receive(:app).and_return(double(test_outdated_days: 2))
        expect(described_class.outdated.to_a).to match_array([ tests[1], tests[5], tests[7] ])
      end

      it "should return standard tests that have not been run since the specified outdated delay", probe_dock: { key: 'a0cc9a663a31' } do
        settings = double test_outdated_days: 4
        expect(described_class.outdated(settings).to_a).to match_array([ tests[5], tests[7] ])
      end
    end

    describe ".failing" do
    
      it "should return standard tests that are failing and active", probe_dock: { key: '0ea768c88ca1' } do
        expect(described_class.failing).to match_array([ tests[2] ])
      end
    end

    describe ".inactive" do
    
      it "should return standard tests that are inactive", probe_dock: { key: '839f48a7da82' } do
        expect(described_class.inactive).to match_array([ tests[4] ])
      end
    end

    describe ".deprecated" do
    
      it "should return deprecated tests", probe_dock: { key: '41c26a95578d' } do
        expect(described_class.deprecated).to match_array([ 3, 6, 8 ].collect{ |i| tests[i] })
      end
    end
  end

  describe ".count_by_category" do
    
    it "should return the list of categories with the corresponding number of tests", probe_dock: { key: '1c1962a3d10d' } do
      run = create :run
      categories = Array.new(3){ create :category }
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[0]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[1]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[1]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: nil
      expect(TestInfo.count_by_category).to match_array([
        { category: categories[0].name, count: 1 },
        { category: categories[1].name, count: 2 },
        { category: categories[2].name, count: 3 },
        { category: nil, count: 1 }
      ])
    end
  end

  describe ".count_by_project" do

    it "should return the list of projects with the corresponding number of tests", probe_dock: { key: 'df42256ee180' } do
      run = create :run
      projects = [ create(:project, name: 'Project A'), create(:project, name: 'Project B'), create(:project, name: 'Project C') ]
      create :test, key: create(:key, user: run.runner, project: projects[0]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[2]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[2]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      expect(TestInfo.count_by_project).to match_array([
        { project: 'Project A', count: 1 },
        { project: 'Project B', count: 3 },
        { project: 'Project C', count: 2 }
      ])
    end
  end

  describe ".count_by_author" do

    it "should return the list of authors with the corresponding number of tests", probe_dock: { key: 'f7a112fd470f' } do
      users = [ create(:user), create(:other_user), create(:another_user) ]
      run = create :run, runner: users[0]
      create :test, key: create(:key, user: users[2]), test_run: run
      create :test, key: create(:key, user: users[1]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      create :test, key: create(:key, user: users[2]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      expect(TestInfo.count_by_author).to match_array([
        { author: users[0], count: 3 },
        { author: users[1], count: 1 },
        { author: users[2], count: 2 }
      ])
    end
  end

  describe "validations" do
    it(nil, probe_dock: { key: '96b7d80190ba' }){ should validate_presence_of(:key) }
    it(nil, probe_dock: { key: '05e2a5e8712f' }){ should validate_presence_of(:key_id) }
    it(nil, probe_dock: { key: '3426c39eade0' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '3c3c1ae0434a' }){ should ensure_length_of(:name).is_at_most(255) }
    it(nil, probe_dock: { key: 'f6c1587dff3d' }){ should validate_presence_of(:author) }
    it(nil, probe_dock: { key: '32a61a67de6e' }){ should validate_presence_of(:project) }
    it(nil, probe_dock: { key: '51552e9426a1' }){ should allow_value(true, false).for(:passing) }
    it(nil, probe_dock: { key: 'e8b1414d2a4a' }){ should_not allow_value(nil, 'abc', 123).for(:passing) }
    it(nil, probe_dock: { key: '1daa6a82952c' }){ should allow_value(true, false).for(:active) }
    it(nil, probe_dock: { key: '25c27702984f' }){ should_not allow_value(nil, 'abc', 123).for(:active) }
    it(nil, probe_dock: { key: '2b686b07d948' }){ should validate_presence_of(:last_run_at) }
    it(nil, probe_dock: { key: '12137ffcc753' }){ should validate_presence_of(:last_run_duration) }
    it(nil, probe_dock: { key: '9f4ca1970ed2' }){ should validate_numericality_of(:last_run_duration).only_integer }

    describe "with an existing test" do
      let!(:test){ create :test }
      it(nil, probe_dock: { key: 'a98a28339c73' }){ should validate_uniqueness_of(:key_id).scoped_to(:project_id) }
    end

    describe "with quick validation" do

      let(:test){ create :test }
      subject{ TestInfo.new.tap{ |t| t.quick_validation = true } }

      it(nil, probe_dock: { key: 'f2b5f79ca573' }){ should_not validate_presence_of(:key) }

      it "should not validate the uniqueness of key_id", probe_dock: { key: 'cd41378e11ce' } do
        expect{ create :test, key: test.key, quick_validation: true }.to raise_unique_error
      end
    end
  end

  describe "associations" do
    it(nil, probe_dock: { key: '716ea42066e5' }){ should belong_to(:author).class_name('User') }
    it(nil, probe_dock: { key: '0d7222048114' }){ should belong_to(:project) }
    it(nil, probe_dock: { key: '908d9ebd3c15' }){ should belong_to(:key).class_name('TestKey') }
    it(nil, probe_dock: { key: 'b5128767d8bf' }){ should have_many(:results).class_name('TestResult') }
    it(nil, probe_dock: { key: '5325459980d4' }){ should belong_to(:effective_result).class_name('TestResult') }
    it(nil, probe_dock: { key: '54dd25e1a5b9' }){ should have_many(:custom_values).class_name('TestValue') }
    it(nil, probe_dock: { key: '3f942894c522' }){ should belong_to(:deprecation).class_name('TestDeprecation') }
    it(nil, probe_dock: { key: 'cc1c7ebded24' }){ should have_many(:deprecations).class_name('TestDeprecation') }
    it(nil, probe_dock: { key: '84e15116a27e' }){ should belong_to(:last_runner).class_name('User') }
    it(nil, probe_dock: { key: '2432961a8bd0' }){ should have_and_belong_to_many(:tags) }
    it(nil, probe_dock: { key: 'f317cd684dc0' }){ should have_and_belong_to_many(:tickets) }
  end

  describe "database table" do
    it(nil, probe_dock: { key: '41a8ca79612d' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '76ee96170b5c' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probe_dock: { key: '480d04cafa66' }){ should have_db_column(:passing).of_type(:boolean).with_options(null: false) }
    it(nil, probe_dock: { key: 'a573e61d78bc' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, probe_dock: { key: 'cab7facebcac' }){ should have_db_column(:key_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: 'cab0ca24ef7c' }){ should have_db_column(:author_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '17e9f6c4987a' }){ should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '213e37d69970' }){ should have_db_column(:category_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: '8bb2389e0e69' }){ should have_db_column(:effective_result_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: 'ebe42ba9512b' }){ should have_db_column(:deprecation_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: 'a38d95731133' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'e6a98cbba2a1' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '33292ca8134d' }){ should have_db_column(:last_runner_id).of_type(:integer).with_options(null: true) }
    it(nil, probe_dock: { key: 'b80a47e5de7d' }){ should have_db_column(:last_run_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'b89a76619893' }){ should have_db_column(:last_run_duration).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '68c77eaabb79' }){ should have_db_index([ :key_id, :project_id ]).unique(true) }
  end
end

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

describe TestInfo, rox: { tags: :unit } do

  context "#breaker" do

    it "should return nil for new tests", rox: { key: '1a5aee484d1f' } do
      TestInfo.new.breaker.should be_nil
    end

    it "should return nil for passing tests", rox: { key: '607f941fbdd2' } do
      create(:test).breaker.should be_nil
    end

    it "should return the runner of the effective result for broken tests", rox: { key: 'd63d2e63d920' } do
      test = create :test, passing: false
      test.breaker.should == test.effective_result.runner
    end
  end

  context "#to_param" do

    it "should return the value of the associated key", rox: { key: '27893c41b7af' } do
      test = create :test
      test.to_param.should == test.key.key
    end
  end

  context "#find_by_key_value" do

    it "should find a test by the value of its associated key", rox: { key: '2b14c1da77ba' } do
      test = create :test
      TestInfo.find_by_key_value(test.key.key).first.should == test
    end
  end

  context ".count_by_category" do
    
    it "should return the list of categories with the corresponding number of tests", rox: { key: '1c1962a3d10d' } do
      run = create :run
      categories = Array.new(3){ create :category }
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[0]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[1]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[1]
      create :test, key: create(:key, user: run.runner), test_run: run, category: categories[2]
      create :test, key: create(:key, user: run.runner), test_run: run, category: nil
      TestInfo.count_by_category.should match_array([
        { category: categories[0].name, count: 1 },
        { category: categories[1].name, count: 2 },
        { category: categories[2].name, count: 3 },
        { category: nil, count: 1 }
      ])
    end
  end

  context ".count_by_project" do

    it "should return the list of projects with the corresponding number of tests", rox: { key: 'df42256ee180' } do
      run = create :run
      projects = [ create(:project, name: 'Project A'), create(:project, name: 'Project B'), create(:project, name: 'Project C') ]
      create :test, key: create(:key, user: run.runner, project: projects[0]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[2]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[2]), test_run: run
      create :test, key: create(:key, user: run.runner, project: projects[1]), test_run: run
      TestInfo.count_by_project.should match_array([
        { project: 'Project A', count: 1 },
        { project: 'Project B', count: 3 },
        { project: 'Project C', count: 2 }
      ])
    end
  end

  context ".count_by_author" do

    it "should return the list of authors with the corresponding number of tests", rox: { key: 'f7a112fd470f' } do
      users = [ create(:user), create(:other_user), create(:another_user) ]
      run = create :run, runner: users[0]
      create :test, key: create(:key, user: users[2]), test_run: run
      create :test, key: create(:key, user: users[1]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      create :test, key: create(:key, user: users[2]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      create :test, key: create(:key, user: users[0]), test_run: run
      TestInfo.count_by_author.should match_array([
        { author: users[0], count: 3 },
        { author: users[1], count: 1 },
        { author: users[2], count: 2 }
      ])
    end
  end

  context "validations" do
    it(nil, rox: { key: '96b7d80190ba' }){ should validate_presence_of(:key) }
    it(nil, rox: { key: '05e2a5e8712f' }){ should validate_presence_of(:key_id) }
    it(nil, rox: { key: '3426c39eade0' }){ should validate_presence_of(:name) }
    it(nil, rox: { key: '3c3c1ae0434a' }){ should ensure_length_of(:name).is_at_most(255) }
    it(nil, rox: { key: 'f6c1587dff3d' }){ should validate_presence_of(:author) }
    it(nil, rox: { key: '32a61a67de6e' }){ should validate_presence_of(:project) }
    it(nil, rox: { key: '51552e9426a1' }){ should allow_value(true, false).for(:passing) }
    it(nil, rox: { key: 'e8b1414d2a4a' }){ should_not allow_value(nil, 'abc', 123).for(:passing) }
    it(nil, rox: { key: '1daa6a82952c' }){ should allow_value(true, false).for(:active) }
    it(nil, rox: { key: '25c27702984f' }){ should_not allow_value(nil, 'abc', 123).for(:active) }
    it(nil, rox: { key: '2b686b07d948' }){ should validate_presence_of(:last_run_at) }
    it(nil, rox: { key: '12137ffcc753' }){ should validate_presence_of(:last_run_duration) }
    it(nil, rox: { key: '9f4ca1970ed2' }){ should validate_numericality_of(:last_run_duration).only_integer }

    context "with an existing test" do
      let!(:test){ create :test }
      it(nil, rox: { key: 'a98a28339c73' }){ should validate_uniqueness_of(:key_id).scoped_to(:project_id) }
    end

    context "with quick validation" do

      let(:test){ create :test }
      subject{ TestInfo.new.tap{ |t| t.quick_validation = true } }

      it(nil, rox: { key: 'f2b5f79ca573' }){ should_not validate_presence_of(:key) }

      it "should not validate the uniqueness of key_id", rox: { key: 'cd41378e11ce' } do
        lambda{ create :test, key: test.key, quick_validation: true }.should raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  context "mass assignment" do

    context "protected", rox: { key: 'e5fc61ed4d67', grouped: true } do
      %w(name passing deprecated_at category_id author_id project_id key_id effective_result_id created_at updated_at last_run_at last_run_duration).each do |attr|
        it{ should_not allow_mass_assignment_of(attr) }
      end
    end
  end

  context "associations" do
    it(nil, rox: { key: '716ea42066e5' }){ should belong_to(:author).class_name('User') }
    it(nil, rox: { key: '0d7222048114' }){ should belong_to(:project) }
    it(nil, rox: { key: '908d9ebd3c15' }){ should belong_to(:key).class_name('TestKey') }
    it(nil, rox: { key: 'b5128767d8bf' }){ should have_many(:results).class_name('TestResult') }
    it(nil, rox: { key: '5325459980d4' }){ should belong_to(:effective_result).class_name('TestResult') }
    it(nil, rox: { key: '54dd25e1a5b9' }){ should have_many(:custom_values).class_name('TestValue') }
    it(nil, rox: { key: '2432961a8bd0' }){ should have_and_belong_to_many(:tags) }
    it(nil, rox: { key: 'f317cd684dc0' }){ should have_and_belong_to_many(:tickets) }
  end

  context "database table" do
    it(nil, rox: { key: '41a8ca79612d' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '76ee96170b5c' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, rox: { key: '480d04cafa66' }){ should have_db_column(:passing).of_type(:boolean).with_options(null: false) }
    it(nil, rox: { key: 'ebe42ba9512b' }){ should have_db_column(:deprecated_at).of_type(:datetime).with_options(null: true) }
    it(nil, rox: { key: 'a573e61d78bc' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, rox: { key: 'cab7facebcac' }){ should have_db_column(:key_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'cab0ca24ef7c' }){ should have_db_column(:author_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '17e9f6c4987a' }){ should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '213e37d69970' }){ should have_db_column(:category_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: '8bb2389e0e69' }){ should have_db_column(:effective_result_id).of_type(:integer).with_options(null: true) }
    it(nil, rox: { key: 'a38d95731133' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'e6a98cbba2a1' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'b80a47e5de7d' }){ should have_db_column(:last_run_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'b89a76619893' }){ should have_db_column(:last_run_duration).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '68c77eaabb79' }){ should have_db_index([ :key_id, :project_id ]).unique(true) }
  end
end

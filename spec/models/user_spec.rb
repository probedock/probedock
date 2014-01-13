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

describe User, rox: { tags: :unit } do

  it "should create empty settings when created", rox: { key: 'b57d46ce9fc4' } do
    expect do
      expect(create(:user).settings).not_to be_nil
    end.to change(Settings::User, :count).by(1)
  end

  context "default values", rox: { key: 'fee0492b0511', grouped: true } do
    its(:roles_mask){ should == 0 }
  end

  describe "metric key" do

    it "should be automatically generated", rox: { key: '76fe1ef9e520' } do
      expect(create(:user).metric_key).to match(/\A[a-z0-9]{5}\Z/)
    end
  end

  context "api keys" do

    it "should contain one active key when a user is created", rox: { key: 'e601c444711e' } do
      create(:user).api_keys.tap do |keys|
        keys.should have(1).item
        keys.first.active.should be_true
      end
    end
  end

  describe "#active_for_authentication?" do

    it "should return the same as active", rox: { key: 'da0d7472cda3' } do
      expect(create(:user, active: true).active_for_authentication?).to be_true
      expect(create(:other_user, active: false).active_for_authentication?).to be_false
    end
  end

  describe "#deletable?" do

    it "should return true for a user without tests, results or counters", rox: { key: '2e4db3280f3f' } do
      user = create :user
      create :test_key, user: user
      expect(user.deletable?).to be_true
    end

    it "should return false for a user with tests", rox: { key: 'f068c4276937' } do
      user = create :user
      key = create :test_key, user: user
      create :test, key: key, runner: create(:another_user)
      expect(user.deletable?).to be_false
    end

    it "should return false for a user with test results", rox: { key: 'f6d7aa711dd4' } do
      user = create :user
      key = create :test_key, user: create(:another_user)
      create :test, key: key, runner: user
      expect(user.deletable?).to be_false
    end

    it "should return false for a user with test counters", rox: { key: 'a70ed3065e37' } do
      user = create :user
      create :test_counter, user: user
      expect(user.deletable?).to be_false
    end
  end

  context "#free_test_keys" do

    it "should return only free test keys", rox: { key: '5e5b331425a0' } do
      user, project = create(:user), create(:project)
      free_keys = Array.new(3){ |i| create :test_key, user: user, project: project, free: true }
      unfree_keys = Array.new(3){ |i| create :test_key, user: user, project: project, free: false }
      expect(user.free_test_keys).to match_array(free_keys)
    end
  end

  context "cache" do

    it "should clear the app_status JSON cache when created", rox: { key: 'ec0d1dfc5e74' } do
      expect(Rails.application.events).to receive(:fire).with('user:created')
      build(:user).save!
    end

    it "should clear the app_status JSON cache when destroyed", rox: { key: 'e13685956480' } do
      user = create :user
      expect(Rails.application.events).to receive(:fire).with('user:destroyed')
      user.destroy
    end
  end

  context "with an existing user" do

    before :each do
      create :user
    end

    it(nil, rox: { key: '1b4e57e85d2b' }){ should validate_uniqueness_of(:name).case_insensitive }
  end

  context "remember token" do

    it "should be 16 characters long", rox: { key: '24df4d561ba2' } do
      10.times{ User.generate_remember_token.length.should == 16 }
    end

    it "should be unique", rox: { key: '470a6dfa0776' } do
      create(:user, remember_token: 'a')
      create(:other_user, remember_token: 'b')
      tokens = [ 'a', 'b', 'c' ]
      User.stub(:generate_remember_token){ tokens.shift }
      User.remember_token.should == 'c'
    end
  end

  context "validations" do
    it(nil, rox: { key: '9d5e1ef7c937' }){ should validate_presence_of(:name) }

    context "with an existing user" do
      let!(:user){ create :user }
      it(nil, rox: { key: 'f9be952c7792' }){ should validate_uniqueness_of(:name).case_insensitive }
    end
  end

  context "associations" do
    it(nil, rox: { key: '28a9398ebe26' }){ should have_many(:test_keys) }
    it(nil, rox: { key: 'bc98127d768c' }){ should have_many(:free_test_keys).class_name('TestKey') }
    it(nil, rox: { key: '16f07fbf52a8' }){ should have_many(:test_infos).with_foreign_key(:author_id) }
    it(nil, rox: { key: '7a371e669906' }){ should have_many(:runs).class_name('TestRun') }
    it(nil, rox: { key: '786e3a4eeefa' }){ should belong_to(:last_run).class_name('TestRun') }
    it(nil, rox: { key: '3161ac222c11' }){ should have_many(:api_keys) }
    it(nil, rox: { key: 'a52d51d6455d' }){ should belong_to(:settings).class_name('Settings::User') }

    it "should delete a user's settings along with it", rox: { key: 'e2ed746b0d27' } do
      user = create :user
      expect{ user.destroy }.to change(Settings::User, :count).by(-1)
    end

    it "should not let a user with tests be deleted", rox: { key: 'f4d6ee32fef5' } do
      user = create :user
      key = create :test_key, user: user
      create :test, key: key, runner: create(:another_user)
      expect{ user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "should not let a user with test results be deleted", rox: { key: '8426c36d61f0' } do
      user = create :user
      key = create :test_key, user: create(:another_user)
      create :test, key: key, runner: user
      expect{ user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "should not let a user with test counters be deleted", rox: { key: '30870e4e3d0f' } do
      user = create :user
      create :test_counter, user: user
      expect{ user.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end

    it "should let a user with no tests, results or counters be deleted", rox: { key: 'ebeae61d4d62' } do
      user = create :user
      key = create :test_key, user: user
      expect do
        expect do
          expect do
            user.destroy
          end.to change(User, :count).by(-1)
        end.to change(ApiKey, :count).by(-1)
      end.to change(TestKey, :count).by(-1)
    end
  end

  context "database table" do
    it(nil, rox: { key: '48b7f46ea463' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'edc6773569db' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, rox: { key: 'c73f8481bbd6' }){ should have_db_column(:email).of_type(:string).with_options(limit: 255) }
    it(nil, rox: { key: '48d53ed224c5' }){ should have_db_column(:encrypted_password).of_type(:string).with_options(limit: 255) }
    it(nil, rox: { key: 'e4b43f2c3c6d' }){ should have_db_column(:remember_token).of_type(:string).with_options(limit: 16) }
    it(nil, rox: { key: '6e6d67322510' }){ should have_db_column(:roles_mask).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, rox: { key: '7f4153e5aa72' }){ should have_db_column(:metric_key).of_type(:string).with_options(null: false, limit: 5) }
    it(nil, rox: { key: 'ab9173bec164' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, rox: { key: 'e1f27f0692ad' }){ should have_db_column(:settings_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '19faaeaea1cf' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'd4502778d426' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: '66d37b1e94bd' }){ should have_db_index(:name).unique(true) }
    it(nil, rox: { key: 'eb053d4f184d' }){ should have_db_index(:metric_key).unique(true) }
    it(nil, rox: { key: '251a37234127' }){ should have_db_index(:settings_id).unique(true) }
  end
end

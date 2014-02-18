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

describe Settings::App, rox: { tags: :unit } do

  it "should clear the app settings cache when saved", rox: { key: '887b487e1f79' } do
    expect(JsonCache).to receive(:clear).with('settings:app')
    described_class.fire 'settings:app:saved'
  end

  it "should fire the settings:app:saved event when saved", rox: { key: '97e924c25dab' } do
    expect(Rails.application.events).to receive(:fire).with('settings:app:saved')
    Settings::App.first.save
  end
  
  context ".get" do

    it "should return the app settings", rox: { key: 'b31e43aad6e5' } do
      Settings::App.get.should == Settings::App.first
    end
  end

  context "#serializable_hash" do

    it "should return a hash of the accessible attributes that are present", rox: { key: '38774deef20d' } do

      # try with the defaults
      Settings::App.first.serializable_hash.should == {
        reports_cache_size: 50,
        tag_cloud_size: 50,
        test_outdated_days: 30,
        test_payloads_lifespan: 7
      }

      # try with a new instance
      subject.ticketing_system_url = 'foo'
      subject.reports_cache_size = 24
      subject.tag_cloud_size = 66
      subject.test_outdated_days = 77
      subject.test_payloads_lifespan = 11
      subject.updated_at = Time.now
      subject.serializable_hash.should == {
        ticketing_system_url: 'foo',
        reports_cache_size: 24,
        tag_cloud_size: 66,
        test_outdated_days: 77,
        test_payloads_lifespan: 11
      }
    end
  end

  context "validations" do
    it(nil, rox: { key: 'c3fa63fb4c24' }){ should validate_presence_of(:reports_cache_size) }
    it(nil, rox: { key: '3491fde8b411' }){ should validate_numericality_of(:reports_cache_size).only_integer }
    it(nil, rox: { key: 'a6f9ff3314ef' }){ should allow_value(0, 1, 10, 25, 50, 1000).for(:reports_cache_size) }
    it(nil, rox: { key: '507a792fc791' }){ should_not allow_value(-1000, -42, -1).for(:reports_cache_size) }
    it(nil, rox: { key: '22b2d2b857f7' }){ should validate_presence_of(:tag_cloud_size) }
    it(nil, rox: { key: '6f008086b6c7' }){ should validate_numericality_of(:tag_cloud_size).only_integer }
    it(nil, rox: { key: 'c1fba08004a0' }){ should allow_value(1, 10, 25, 50, 1000).for(:tag_cloud_size) }
    it(nil, rox: { key: '90db26f1e7a8' }){ should_not allow_value(-1000, -42, -1, 0).for(:tag_cloud_size) }
    it(nil, rox: { key: 'b8f9230cdf84' }){ should validate_presence_of(:test_outdated_days) }
    it(nil, rox: { key: 'd9d87ff57a05' }){ should validate_numericality_of(:test_outdated_days).only_integer }
    it(nil, rox: { key: '0ff5756f4e59' }){ should allow_value(1, 10, 25, 50, 1000).for(:test_outdated_days) }
    it(nil, rox: { key: '855a877b5e9d' }){ should_not allow_value(-1000, -42, -1, 0).for(:test_outdated_days) }
    it(nil, rox: { key: '87cce3001f23' }){ should ensure_length_of(:ticketing_system_url).is_at_most(255) }
    it(nil, rox: { key: '03f3dde4d133' }){ should validate_numericality_of(:test_payloads_lifespan).only_integer.is_greater_than_or_equal_to(1) }
  end

  context "database table" do

    it "should be stored in the app_settings table", rox: { key: '1c136c35641e' } do
      Settings::App.table_name.should == 'app_settings'
    end

    it(nil, rox: { key: '2fdda1efe6c0' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '78bdc69eb480' }){ should have_db_column(:ticketing_system_url).of_type(:string).with_options(limit: 255) }
    it(nil, rox: { key: '428ab528584e' }){ should have_db_column(:reports_cache_size).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'b7d20d6e1a23' }){ should have_db_column(:tag_cloud_size).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '92e5fc23677f' }){ should have_db_column(:test_outdated_days).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '56f8ac256182' }){ should have_db_column(:test_payloads_lifespan).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'f779a63e0e35' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end

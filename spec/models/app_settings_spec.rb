# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

describe Settings::App, probedock: { tags: :unit } do

  context ".get" do

    it "should return the app settings", probedock: { key: 'b31e43aad6e5' } do
      expect(Settings::App.get).to eq(Settings::App.first)
    end
  end

  context "#serializable_hash" do

    it "should return a hash of the accessible attributes that are present", probedock: { key: '38774deef20d' } do

      # try with the defaults
      expect(Settings::App.first.serializable_hash).to eq({
        reports_cache_size: 50,
        tag_cloud_size: 50,
        test_outdated_days: 30,
        test_payloads_lifespan: 7,
        test_runs_lifespan: 60
      })

      # try with a new instance
      subject.ticketing_system_url = 'foo'
      subject.reports_cache_size = 24
      subject.tag_cloud_size = 66
      subject.test_outdated_days = 77
      subject.test_payloads_lifespan = 11
      subject.test_runs_lifespan = 50
      subject.updated_at = Time.now
      expect(subject.serializable_hash).to eq({
        ticketing_system_url: 'foo',
        reports_cache_size: 24,
        tag_cloud_size: 66,
        test_outdated_days: 77,
        test_payloads_lifespan: 11,
        test_runs_lifespan: 50
      })
    end
  end

  context "validations" do
    it(nil, probedock: { key: 'c3fa63fb4c24' }){ should validate_presence_of(:reports_cache_size) }
    it(nil, probedock: { key: '3491fde8b411' }){ should validate_numericality_of(:reports_cache_size).only_integer }
    it(nil, probedock: { key: 'a6f9ff3314ef' }){ should allow_value(0, 1, 10, 25, 50, 1000).for(:reports_cache_size) }
    it(nil, probedock: { key: '507a792fc791' }){ should_not allow_value(-1000, -42, -1).for(:reports_cache_size) }
    it(nil, probedock: { key: '22b2d2b857f7' }){ should validate_presence_of(:tag_cloud_size) }
    it(nil, probedock: { key: '6f008086b6c7' }){ should validate_numericality_of(:tag_cloud_size).only_integer }
    it(nil, probedock: { key: 'c1fba08004a0' }){ should allow_value(1, 10, 25, 50, 1000).for(:tag_cloud_size) }
    it(nil, probedock: { key: '90db26f1e7a8' }){ should_not allow_value(-1000, -42, -1, 0).for(:tag_cloud_size) }
    it(nil, probedock: { key: 'b8f9230cdf84' }){ should validate_presence_of(:test_outdated_days) }
    it(nil, probedock: { key: 'd9d87ff57a05' }){ should validate_numericality_of(:test_outdated_days).only_integer }
    it(nil, probedock: { key: '0ff5756f4e59' }){ should allow_value(1, 10, 25, 50, 1000).for(:test_outdated_days) }
    it(nil, probedock: { key: '855a877b5e9d' }){ should_not allow_value(-1000, -42, -1, 0).for(:test_outdated_days) }
    it(nil, probedock: { key: '87cce3001f23' }){ should validate_length_of(:ticketing_system_url).is_at_most(255) }
    it(nil, probedock: { key: '03f3dde4d133' }){ should validate_numericality_of(:test_payloads_lifespan).only_integer.is_greater_than_or_equal_to(1) }
    it(nil, probedock: { key: 'f98c12a57041' }){ should validate_numericality_of(:test_runs_lifespan).only_integer.is_greater_than_or_equal_to(1) }
  end

  context "database table" do

    it "should be stored in the app_settings table", probedock: { key: '1c136c35641e' } do
      expect(Settings::App.table_name).to eq('app_settings')
    end

    it(nil, probedock: { key: '2fdda1efe6c0' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '78bdc69eb480' }){ should have_db_column(:ticketing_system_url).of_type(:string).with_options(limit: 255) }
    it(nil, probedock: { key: '428ab528584e' }){ should have_db_column(:reports_cache_size).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'b7d20d6e1a23' }){ should have_db_column(:tag_cloud_size).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '92e5fc23677f' }){ should have_db_column(:test_outdated_days).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '56f8ac256182' }){ should have_db_column(:test_payloads_lifespan).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '09ee1947a4c0' }){ should have_db_column(:test_runs_lifespan).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'f779a63e0e35' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end

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
        user_registration_enabled: false
      })

      # try with a new instance
      subject.user_registration_enabled = true
      subject.updated_at = Time.now

      expect(subject.serializable_hash).to eq({
        user_registration_enabled: true
      })
    end
  end

  context "validations" do
    it(nil, probedock: { key: 'cbpl' }){ should allow_value(true, false).for(:user_registration_enabled) }
    it(nil, probedock: { key: '4mtr' }){ should_not allow_value(nil, 'foo').for(:user_registration_enabled) }
  end

  context "database table" do

    it "should be stored in the app_settings table", probedock: { key: '1c136c35641e' } do
      expect(Settings::App.table_name).to eq('app_settings')
    end

    it(nil, probedock: { key: '2fdda1efe6c0' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '1vdf' }){ should have_db_column(:user_registration_enabled).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: 'f779a63e0e35' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end
end

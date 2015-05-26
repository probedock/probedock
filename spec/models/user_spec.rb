# Copyright (c) 2015 Probe Dock
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

describe User, probe_dock: { tags: :unit } do

  context "default values", probe_dock: { key: 'fee0492b0511', grouped: true } do
    its(:roles_mask){ should eq(0) }
  end

  context "with an existing user" do
    before(:each){ create :user }
    it(nil, probe_dock: { key: '1b4e57e85d2b' }){ should validate_uniqueness_of(:name) }
  end

  context "validations" do
    it(nil, probe_dock: { key: '9d5e1ef7c937' }){ should validate_presence_of(:name) }

    context "with an existing user" do
      let!(:user){ create :user }
      it(nil, probe_dock: { key: 'f9be952c7792' }){ should validate_uniqueness_of(:name) }
    end
  end

  context "associations" do
    it(nil, probe_dock: { key: '28a9398ebe26' }){ should have_many(:test_keys) }
    it(nil, probe_dock: { key: 'bc98127d768c' }){ should have_many(:free_test_keys).class_name('TestKey') }
    it(nil, probe_dock: { key: '7a371e669906' }){ should have_many(:test_payloads).class_name('TestPayload') }
    it(nil, probe_dock: { key: 'a5dca889075c' }){ should have_many(:test_payloads) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '48b7f46ea463' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: 'edc6773569db' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 25) }
    it(nil, probe_dock: { key: '6e6d67322510' }){ should have_db_column(:roles_mask).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probe_dock: { key: 'ab9173bec164' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, probe_dock: { key: '19faaeaea1cf' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'd4502778d426' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '66d37b1e94bd' }){ should have_db_index(:name).unique(true) }
  end
end

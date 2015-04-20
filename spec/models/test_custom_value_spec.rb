# Copyright (c) 2015 42 inside
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

describe TestCustomValue, probe_dock: { tags: :unit } do

  context "validations" do
    it(nil, probe_dock: { key: '5f97b421e2b2' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '3ce512bc0951' }){ should validate_length_of(:name).is_at_most(50) }
    it(nil, probe_dock: { key: '15220b99b6c9' }){ should allow_value('').for(:contents) }
  end

  context "associations" do
    it(nil, probe_dock: { key: 'd43992d77922' }){ should have_and_belong_to_many(:test_descriptions) }
  end

  context "database table" do
    it(nil, probe_dock: { key: 'a83c6e1ea226' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '023efd6a7ef0' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probe_dock: { key: '37838a3713c2' }){ should have_db_column(:contents).of_type(:text).with_options(null: false) }
  end
end

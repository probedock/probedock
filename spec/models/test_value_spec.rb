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

describe TestValue, rox: { tags: :unit } do

  context "validations" do
    it(nil, rox: { key: 'e92ef94be7cd' }){ should validate_presence_of(:test_info) }
    it(nil, rox: { key: '5f97b421e2b2' }){ should validate_presence_of(:name) }
    it(nil, rox: { key: '3ce512bc0951' }){ should ensure_length_of(:name).is_at_most(50) }
    it(nil, rox: { key: '15220b99b6c9' }){ should allow_value('').for(:contents) }

    it "should allow contents with 65535 bytes", rox: { key: '16b77606693a' } do
      contents = 'x' * 65535
      value = build :test_value, contents: contents
      expect(value.valid?).to be(true)
    end

    it "should ensure that the contents are not longer than 65535 bytes", rox: { key: 'dfa244369dd1' } do
      contents = 'x' * 65534
      contents << "\u3042"
      value = build :test_value, contents: contents
      expect(value.valid?).to be(false)
    end

    context "with an existing value" do
      let!(:test_value){ create :test_value }
      it(nil, rox: { key: '3821045055d7' }){ should validate_uniqueness_of(:name).scoped_to(:test_info_id) }
    end
  end

  context "associations" do
    it(nil, rox: { key: 'd43992d77922' }){ should belong_to(:test_info) }
  end

  context "database table" do
    it(nil, rox: { key: 'a83c6e1ea226' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '023efd6a7ef0' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, rox: { key: '37838a3713c2' }){ should have_db_column(:contents).of_type(:text).with_options(null: false) }
    it(nil, rox: { key: '07774b12df6f' }){ should have_db_column(:test_info_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'bb180a3fb1d4' }){ should have_db_index([ :test_info_id, :name ]).unique(true) }
  end
end

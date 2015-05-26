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
# encoding: UTF-8
require 'spec_helper'

describe Tag, probe_dock: { tags: :unit } do

  context "validations" do
    it(nil, probe_dock: { key: 'bd99f663c361' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '48e4e5d511b8' }){ should validate_length_of(:name).is_at_most(50) }
    it(nil, probe_dock: { key: '4d3ee76ace2c' }){ should allow_value('unit', 'integration', 'FLOW', '098', 'my-tag', 'under_scored').for(:name) }
    it(nil, probe_dock: { key: '70333ff9d379' }){ should_not allow_value('$$$', 'tag with space').for(:name) }

    context "with an existing tag" do
      let!(:tag){ create :unit_tag }

      it(nil, probe_dock: { key: '193b8fba796c' }){ should validate_uniqueness_of(:name).scoped_to(:organization_id) }

      it "should not validate the uniqueness of name with quick validation", probe_dock: { key: '5a54a294e171' } do
        expect{ Tag.new.tap{ |t| t.name = tag.name; t.organization = tag.organization; t.quick_validation = true }.save! }.to raise_unique_error
      end
    end
  end

  context "associations" do
    it(nil, probe_dock: { key: '37d108f64ecf' }){ should have_and_belong_to_many(:test_descriptions) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '9769e493bce9' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '308268b6ab43' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probe_dock: { key: 'e50992d6d9bc' }){ should have_db_index([ :name, :organization_id ]).unique(true) }
  end
end

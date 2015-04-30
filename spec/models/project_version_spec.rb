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

describe ProjectVersion do

  context "validations" do
    it(nil, probe_dock: { key: '2a51543c8f94' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '57f900fc8f42' }){ should validate_length_of(:name).is_at_most(255) }
    it(nil, probe_dock: { key: '0e4c2027f0d9' }){ should validate_presence_of(:project) }

    context "with an existing version" do
      let!(:project_version){ create :project_version }
      it(nil, probe_dock: { key: 'a0a0897d511c' }){ should validate_uniqueness_of(:name).scoped_to(:project_id) }

      context "with quick validation" do
        before(:each){ subject.quick_validation = true }
        it(nil, probe_dock: { key: '832fadbac6bd' }){ should_not validate_presence_of(:project) }

        it "should not validate the uniqueness of name", probe_dock: { key: 'c98c75e7717b' } do
          subject.project = project_version.project
          subject.name = project_version.name
          expect{ subject.save! }.to raise_unique_error
        end
      end
    end
  end

  context "associations" do
    it(nil, probe_dock: { key: 'f6581e00e16f' }){ should belong_to(:project) }
  end

  context "database table" do
    it(nil, probe_dock: { key: '55f10dca159e' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '4f8bf6a84917' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probe_dock: { key: 'd98e4624f114' }){ should have_db_column(:project_id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '4b3cc531f1f4' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '043683ddfcb8' }){ should have_db_index([ :name, :project_id ]).unique(true) }
  end
end

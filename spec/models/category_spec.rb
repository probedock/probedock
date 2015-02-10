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

describe Category do

  describe "metric key" do

    it "should be automatically generated", probe_dock: { key: 'eb3048ef9279' } do
      expect(create(:category).metric_key).to match(/\A[a-z0-9]{5}\Z/)
    end
  end

  context "validations" do
    it(nil, probe_dock: { key: 'ba6a34e19289' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '5e7b05650570' }){ should ensure_length_of(:name).is_at_most(255) }

    context "with an existing category" do
      let!(:category){ create :category }
      it(nil, probe_dock: { key: '4fe83eacb8be' }){ should validate_uniqueness_of(:name).case_insensitive }

      context "with quick validation" do
        before(:each){ subject.quick_validation = true }

        it "should not validate the uniqueness of name", probe_dock: { key: 'dd74d78ce79b' } do
          subject.name = category.name
          expect{ subject.save! }.to raise_unique_error
        end
      end
    end
  end

  context "associations" do
    it(nil, probe_dock: { key: '5a536979f346' }){ should have_many(:test_infos) }
  end
  
  context "database table" do
    it(nil, probe_dock: { key: '4c2d12b4392b' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '36105d8b309b' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probe_dock: { key: '4992531fee82' }){ should have_db_column(:metric_key).of_type(:string).with_options(null: false, limit: 5) }
    it(nil, probe_dock: { key: '45ec9284a110' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '542503b7d3f5' }){ should have_db_index(:name).unique(true) }
    it(nil, probe_dock: { key: 'e28770bb0cb4' }){ should have_db_index(:metric_key).unique(true) }
  end
end

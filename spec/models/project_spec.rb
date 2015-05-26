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

describe Project do

  it "should have no tests by default", probe_dock: { key: '92609fb6cfd4' } do
    expect(subject.tests_count).to eq(0)
  end

  it "should have no deprecated tests by default", probe_dock: { key: '1802e31de320' } do
    expect(subject.deprecated_tests_count).to eq(0)
  end

  describe "when created" do
    subject{ create :project }

    it "should have a well-formatted api id", probe_dock: { key: '2820535dcaf3' } do
      expect(subject.api_id).to match(/\A[a-z0-9]{12}\Z/i)
    end
  end

  describe "validations" do
    it(nil, probe_dock: { key: '439478e8b142' }){ should validate_presence_of(:name) }
    it(nil, probe_dock: { key: '38a831c819f7' }){ should validate_length_of(:name).is_at_most(50) }
  end

  describe "associations" do
    it(nil, probe_dock: { key: '7a1d3aff362b' }){ should have_many(:tests).class_name('ProjectTest') }
  end

  describe "database table" do
    it(nil, probe_dock: { key: '354227570c24' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probe_dock: { key: '66b088f28c76' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probe_dock: { key: 'df86a430816f' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 12) }
    it(nil, probe_dock: { key: '89de5255730b' }){ should have_db_column(:tests_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probe_dock: { key: 'eba1a511e15f' }){ should have_db_column(:deprecated_tests_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probe_dock: { key: '20bb321bfa30' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: 'acf557d6db43' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probe_dock: { key: '6c8efd97b251' }){ should have_db_index(:api_id).unique(true) }
  end
end

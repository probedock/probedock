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

describe Category do

  context 'validations' do
    it(nil, probedock: { key: 'd9r4' }){ should have_validations_on(:name, :organization)}
    it(nil, probedock: { key: 'ba6a34e19289' }){ should validate_presence_of(:name) }
    it(nil, probedock: { key: '5e7b05650570' }){ should validate_length_of(:name).is_at_most(50) }

    context 'with an existing category' do
      let!(:category){ create :category }

      it(nil, probedock: { key: '4fe83eacb8be' }){ should validate_uniqueness_of(:name).scoped_to(:organization_id) }

      context 'with quick validation' do
        before(:each){ subject.quick_validation = true }

        it 'should not validate the uniqueness of name', probedock: { key: 'dd74d78ce79b' } do
          subject.name = category.name
          subject.organization = category.organization
          expect{ subject.save! }.to raise_unique_error
        end
      end
    end
  end

  context 'associations' do
    it(nil, probedock: { key: 'dk4z' }){ should have_associations(:organization, :test_descriptions, :test_results, :test_payloads) }
    it(nil, probedock: { key: 'wnlv' }){ should belong_to(:organization) }
    it(nil, probedock: { key: '5a536979f346' }){ should have_many(:test_descriptions) }
    it(nil, probedock: { key: '7e3k' }){ should have_many(:test_results) }
    it(nil, probedock: { key: 'mo4v' }){ should have_and_belong_to_many(:test_payloads) }
  end

  context "database table" do
    it(nil, probedock: { key: '2sfh' }){ should have_db_columns(:id, :organization_id, :name, :created_at, )}
    it(nil, probedock: { key: '4c2d12b4392b' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '1dnz' }){ should have_db_column(:organization_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '36105d8b309b' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probedock: { key: '45ec9284a110' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '542503b7d3f5' }){ should have_db_index([ :name, :organization_id ]).unique(true) }
  end
end

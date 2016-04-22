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

RSpec.describe Organization, type: :model, probedock: { tags: :unit } do
  it 'should have a well-formatted API ID when created', probedock: { key: 'po7e' } do
    expect(create(:organization).api_id).to match(/\A[a-z0-9]{5}\Z/)
  end

  it 'should save a normalized version of its name when created', probedock: { key: 'xpfs' } do
    organization = create(:organization, name: 'FoObAr')
    expect(organization.name).to eq('FoObAr')
    expect(organization.normalized_name).to eq('foobar')
  end

  describe '#active' do
    let! :organizations do
      [
        create(:organization, active: true),
        create(:organization, active: false),
        create(:organization, active: false),
        create(:organization, active: true),
        create(:organization, active: false)
      ]
    end

    it 'should return a relation matching active organizations', probedock: { key: 'feri' } do
      expect(described_class.active.to_a).to match_array([ organizations[0], organizations[3] ])
    end
  end

  describe '#public?' do
    it 'should return the value of the :public_access attribute', probedock: { key: 'tlv1' } do
      expect(described_class.new(public_access: true).public?).to be(true)
      expect(described_class.new(public_access: false).public?).to be(false)
    end
  end

  describe '#effective_name' do
    it "should return the display name of the organization if it's set, otherwise it should return the name", probedock: { key: '3250' } do
      organization = described_class.new(name: 'foobar')
      expect(organization.effective_name).to eq('foobar')

      organization.display_name = 'FoObAr'
      expect(organization.effective_name).to eq('FoObAr')
    end
  end

  describe 'validations' do
    it(nil, probedock: { key: 'bejt' }){ should have_validations_on(:name, :display_name, :public_access) }
    it(nil, probedock: { key: 'swud' }){ should validate_presence_of(:name) }
    it(nil, probedock: { key: '5v9o' }){ should validate_length_of(:name).is_at_most(50) }
    it(nil, probedock: { key: '8f40' }){ should allow_value('foo', 'FoO', 'foo-bar', 'Foo-Bar-Baz').for(:name) }
    it(nil, probedock: { key: 'l63m' }){ should_not allow_value('---', '-foo', 'foo-', '$oo', 'Yee haw').for(:name) }
    it(nil, probedock: { key: 'qfqi' }){ should validate_presence_of(:display_name) }
    it(nil, probedock: { key: 'ddxn' }){ should validate_length_of(:display_name).is_at_most(50) }
    it(nil, probedock: { key: 'y9jd' }){ should allow_value(true, false).for(:public_access) }
    it(nil, probedock: { key: 's2rh' }){ should_not allow_value(nil, 'foo').for(:public_access) }
    it(nil, probedock: { key: 'voxa' }){ should validate_exclusion_of(:name).in_array(described_class::RESERVED_NAMES) }

    describe 'with an existing organization' do
      before(:each){ create(:organization) }
      it(nil, probedock: { key: 'rv48' }){ should validate_uniqueness_of(:name).case_insensitive }
    end
  end

  describe 'associations' do
    it(nil, probedock: { key: '2k05' }){ should have_associations(:memberships, :projects, :reports) }
    it(nil, probedock: { key: 'rynz' }){ should have_many(:memberships) }
    it(nil, probedock: { key: 'pjs5' }){ should have_many(:projects) }
    it(nil, probedock: { key: 'itmq' }){ should have_many(:reports) }
  end

  describe 'database table' do
    it(nil, probedock: { key: 'hga0' }){ should have_db_columns(:id, :api_id, :name, :display_name, :normalized_name, :active, :public_access, :memberships_count, :projects_count, :created_at, :updated_at) }
    it(nil, probedock: { key: 'cqi4' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: '9hi0' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 5) }
    it(nil, probedock: { key: 'llfp' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probedock: { key: '4lp8' }){ should have_db_column(:display_name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probedock: { key: 'matj' }){ should have_db_column(:normalized_name).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, probedock: { key: 'xbi5' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: 'l4ty' }){ should have_db_column(:public_access).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: '14eb' }){ should have_db_column(:memberships_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'wkwc' }){ should have_db_column(:projects_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'bcoi' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: '7aqy' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'ithq' }){ should have_db_index(:api_id).unique(true) }
    it(nil, probedock: { key: '7pik' }){ should have_db_index(:normalized_name).unique(true) }
  end
end

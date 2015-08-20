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

RSpec.describe Email, probedock: { tags: :unit } do
  it "should ensure the address is in lowercase", probedock: { key: 'l7lv' } do
    expect(Email.new(address: 'FoO@example.COM').tap(&:save!).address).to eq('foo@example.com')
  end

  describe "validations" do
    it(nil, probedock: { key: 'poya' }){ should validate_presence_of(:address) }
    it(nil, probedock: { key: 'wj3z' }){ should validate_length_of(:address).is_at_most(255) }

    describe "with an existing e-mail" do
      before(:each){ create :email }
      it(nil, probedock: { key: 'uwbb' }){ should validate_uniqueness_of(:address).case_insensitive }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: 'mwdz' }){ should belong_to(:user) }
    it(nil, probedock: { key: '9x93' }){ should have_one(:primary_user).class_name('User').with_foreign_key(:primary_email_id) }
  end

  describe "database table" do
    it(nil, probedock: { key: '4kw6' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'lvst' }){ should have_db_column(:address).of_type(:string).with_options(null: false, limit: 255) }
    it(nil, probedock: { key: '29i3' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: 'u3z3' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: '0z8d' }){ should have_db_index(:address).unique(true) }
  end
end

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

RSpec.describe UserRegistration, type: :model, probedock: { tags: :unit } do
  it "should have a well-formatted API ID when created", probedock: { key: '75ty' } do
    expect(create(:registration).api_id).to match(/\A[a-z0-9]{5}\Z/)
  end

  it "should have an OTP and expire in 1 week when created", probedock: { key: 'oqdz' } do
    registration = create :registration
    expect(registration.otp).to be_present
    expect(registration.expires_at).to be_present
    expect(registration.expires_at).to be <= 1.week.from_now
    expect(registration.expires_at - 1.week.from_now).to be >= -5
  end

  it "should remove the OTP and expiration date and set its completion date when completed", probedock: { key: 'jak5' } do

    registration = create :registration
    registration.completed = true
    registration.save!

    expect(registration.otp).to be_blank
    expect(registration.expires_at).to be_blank
    expect(registration.completed_at).to be_present
    expect(registration.completed_at - Time.now).to be <= 0
    expect(registration.completed_at - Time.now).to be >= -5
  end

  it "should create an admin membership (if an organization is set) when created", probedock: { key: 'lchd' } do

    registration = nil

    expect do
      registration = create :registration
    end.to change(Membership, :count).by(1)

    membership = registration.organization.memberships.first
    expect(membership).to be_present
    expect(membership.user).to eq(registration.user)
    expect(membership.organization).to eq(registration.organization)
    expect(membership.organization_email).to eq(registration.user.primary_email)
    expect(membership.roles).to match_array(%i(admin))
    expect(membership.accepted_at).to eq(registration.created_at)
  end

  describe "#completed?" do
    it "should return the value of the :completed attribute", probedock: { key: '2vuh' } do
      expect(described_class.new(completed: true).completed?).to be(true)
      expect(described_class.new(completed: false).completed?).to be(false)
    end
  end

  describe "validations" do
    it(nil, probedock: { key: 'rhjn' }){ should validate_presence_of(:user) }

    describe "with an existing registration" do
      before(:each){ create :registration }
      it(nil, probedock: { key: 'h02d' }){ should validate_uniqueness_of(:user_id) }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: 'hcj6' }){ should belong_to(:user).autosave(true) }
    it(nil, probedock: { key: 'ae26' }){ should belong_to(:organization).autosave(true) }
  end

  describe "database table" do
    # TODO: add unique index on user_id and organization_id (one for each)
    it(nil, probedock: { key: '9ykc' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'cnw8' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 5) }
    it(nil, probedock: { key: 'ov8j' }){ should have_db_column(:otp).of_type(:string).with_options(null: true, limit: 150) }
    it(nil, probedock: { key: '1bwo' }){ should have_db_column(:completed).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: '9ko3' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'mshi' }){ should have_db_column(:organization_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: 'ycwh' }){ should have_db_column(:expires_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: 'fdyh' }){ should have_db_column(:completed_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: 'ksgf' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'kcv6' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'ibve' }){ should have_db_index(:api_id).unique(true) }
    it(nil, probedock: { key: '7j8a' }){ should have_db_index(:otp).unique(true) }
  end
end

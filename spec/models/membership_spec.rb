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

RSpec.describe Membership, type: :model, probedock: { tags: :unit } do
  it "should have a well-formatted API ID when created", probedock: { key: 'lm7p' } do
    expect(create(:membership).api_id).to match(/\A[a-z0-9]{12}\Z/)
  end

  it "should have the following available roles: admin", probedock: { key: 'lqdd' } do
    expect(described_class.valid_roles).to match_array(%i(admin))
  end

  it "should have an OTP and expire in 1 week when created", probedock: { key: '7zrx' } do
    membership = create :membership, user: nil, organization_email: create(:email)
    expect(membership.otp).to be_present
    expect(membership.expires_at).to be_present
    expect(membership.expires_at).to be <= 1.week.from_now
    expect(membership.expires_at - 1.week.from_now).to be >= -5
  end

  it "should remove the OTP and expiration date and set its acceptation date when completed", probedock: { key: 'tssi' } do

    membership = create :membership, user: nil, organization_email: create(:email)
    membership.user = create :user
    membership.save!

    expect(membership.otp).to be_blank
    expect(membership.expires_at).to be_blank
    expect(membership.accepted_at).to be_present
    expect(membership.accepted_at - Time.now).to be <= 0
    expect(membership.accepted_at - Time.now).to be >= -5
  end

  it "should activate the organization e-mail when the user is set", probedock: { key: 'o54d' } do

    user = create :user

    email = create :email
    membership = create :membership, organization: create(:organization), organization_email: email, user: nil

    email.reload
    expect(email.active).to be(false)
    expect(email.user).to be_blank

    membership.user = user
    membership.save!

    email.reload
    expect(email.active).to be(true)
    expect(email.user).to eq(user)
  end

  describe "validations" do
    it(nil, probedock: { key: '7kch' }){ should validate_presence_of(:organization) }
    it(nil, probedock: { key: 'gqa7' }){ should_not validate_presence_of(:organization_email) }

    it "should not allow an organization e-mail that is assigned to another user", probedock: { key: 'x0om' } do

      another_user = create :user

      membership = build :membership, user: create(:user)
      expect(membership).to be_valid

      membership.organization_email = another_user.primary_email
      membership.validate
      expect(membership).not_to be_valid
      expect(membership.errors.first).to eq([ :organization_email, 'must be owned by the user' ])
    end

    it "should not allow a technical user that already belongs to another organization", probedock: { key: 'dpli' } do

      technical_user = create :technical_user, organization: create(:organization)

      membership = build :membership, organization: create(:organization)
      expect(membership).to be_valid

      membership.user = technical_user
      membership.organization_email = nil
      membership.validate
      expect(membership).not_to be_valid
      expect(membership.errors.first).to eq([ :user_id, 'must not be a technical user of another organization' ])
    end

    describe "with an existing membership" do
      before(:each){ create :membership }
      it(nil, probedock: { key: 'vuyt' }){ should validate_uniqueness_of(:user_id).scoped_to(:organization_id) }
    end

    describe "with a user" do
      subject{ Membership.new user: create(:user) }
      it(nil, probedock: { key: 'slrn' }){ should validate_presence_of(:organization_email) }
    end

    describe "with a technical user" do
      subject{ Membership.new user: create(:technical_user, organization: create(:organization)) }
      it(nil, probedock: { key: 't28y' }){ should validate_absence_of(:organization_email) }
    end
  end

  describe "associations" do
    it(nil, probedock: { key: 'nu6p' }){ should belong_to(:user) }
    it(nil, probedock: { key: 'ipb4' }){ should belong_to(:organization).counter_cache(true) }
    it(nil, probedock: { key: 'w314' }){ should belong_to(:organization_email).class_name('Email') }
  end

  describe "database table" do
    it(nil, probedock: { key: '7yt7' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'snt8' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 12) }
    it(nil, probedock: { key: 'elsd' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: 'sct5' }){ should have_db_column(:organization_id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'l6qn' }){ should have_db_column(:organization_email_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: 'hx8a' }){ should have_db_column(:roles_mask).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'sfvp' }){ should have_db_column(:otp).of_type(:string).with_options(null: true, limit: 255) }
    it(nil, probedock: { key: '95a4' }){ should have_db_column(:expires_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: 'fx9l' }){ should have_db_column(:accepted_at).of_type(:datetime).with_options(null: true) }
    it(nil, probedock: { key: '6c72' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'vqcf' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'tilg' }){ should have_db_index(:api_id).unique(true) }
    it(nil, probedock: { key: 'njg7' }){ should have_db_index(:otp).unique(true) }
    it(nil, probedock: { key: '2t0d' }){ should have_db_index([ :user_id, :organization_id ]).unique(true) }
  end
end

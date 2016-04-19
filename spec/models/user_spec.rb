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

describe User, probedock: { tags: :unit } do
  it 'should have the following available roles: admin', probedock: { key: 'vtfr' } do
    expect(described_class.valid_roles).to match_array(%i(admin))
  end

  it 'should have a secure password', probedock: { key: 'po11' } do
    expect(subject).to have_secure_password
  end

  it 'should have a well-formatted API ID when created', probedock: { key: 'kupk' } do
    expect(create(:user).api_id).to match(/\A[a-z0-9]{5}\Z/)
  end

  it 'should complete its associated registration and activate its primary e-mail and organization when activated', probedock: { key: 'wbmz' } do

    user = create(:new_user)
    organization = create(:new_organization)
    expect(user.active).to be(false)
    expect(user.primary_email.active).to be(false)
    expect(organization.active).to be(false)

    registration = create(:registration, user: user, organization: organization)
    expect(registration.completed).to be(false)
    expect(registration.completed_at).to be_blank
    expect(registration.otp).to be_present
    expect(registration.expires_at).to be_present

    user.active = true
    user.password = 'sekr3t'
    user.password_confirmation = 'sekr3t'
    user.save!

    expect(user.primary_email.active).to be(true)

    organization.reload
    expect(organization.active).to be(true)

    registration.reload
    expect(registration.completed).to be(true)
    expect(registration.completed_at).to be_present
    expect(registration.otp).to be_blank
    expect(registration.expires_at).to be_blank
  end

  describe '#technical?' do
    it 'should return the value of the :technical attribute', probedock: { key: 'dek7' } do
      expect(described_class.new(technical: true).technical?).to be(true)
      expect(described_class.new(technical: false).technical?).to be(false)
    end
  end

  describe '#human?' do
    it 'should return the negated value of the :technical attribute', probedock: { key: 'jh3l' } do
      expect(described_class.new(technical: true).human?).to be(false)
      expect(described_class.new(technical: false).human?).to be(true)
    end
  end

  describe '#active?' do
    it 'should return the value of the :active attribute', probedock: { key: 'syyq' } do
      expect(described_class.new(active: true).active?).to be(true)
      expect(described_class.new(active: false).active?).to be(false)
    end
  end

  describe '#primary_email=' do
    it "should add the e-mail to the user's list of e-mails if he has no e-mails yet", probedock: { key: 'rvwg' } do

      user = described_class.new
      expect(user.emails).to be_empty

      primary_email = create(:email)
      user.primary_email = primary_email
      expect(user.emails).to match_array([ primary_email ])
    end

    it "should not add the e-mail to the user's list of e-mails if he already has e-mails", probedock: { key: 'nif5' } do

      user = create(:user)
      expect(user.emails).to have(1).item
      primary_email = user.primary_email

      new_primary_email = create(:email)
      user.primary_email = new_primary_email
      expect(user.emails).to match_array([ primary_email ])
    end
  end

  describe '#generate_auth_token' do
    let(:user){ create(:user) }
    subject{ user.generate_auth_token }

    it 'should generate a valid JWT token that can be used to authenticate the user', probedock: { key: '1g7r' } do

      claims = nil
      expect{ claims = JSON::JWT.decode subject, Rails.application.secrets.jwt_secret }.not_to raise_error

      expect(claims['iss']).to eq(user.api_id)
      expect(claims['nbf'] - Time.now.to_i).to be <= 0
      expect(claims['nbf'] - Time.now.to_i).to be >= -5
      expect(claims.key?('exp')).to be(false)
    end
  end

  describe '#member_of?' do
    let(:organization){ create(:organization) }
    let(:another_organization){ create(:organization) }
    let(:user){ create(:org_member, organization: organization) }

    it 'should indicate whether the user is a member of the given organization', probedock: { key: '44ct' } do
      expect(user.member_of?(organization)).to be(true)
      expect(user.member_of?(another_organization)).to be(false)
    end
  end

  describe '#membership_in' do
    let(:organization){ create(:organization) }
    let(:another_organization){ create(:organization) }
    let(:user){ create(:org_member, organization: organization) }

    it 'should return the membership of the user in the given organization, if any', probedock: { key: 'd1v6' } do
      expect(user.membership_in(organization)).to eq(organization.memberships.first)
      expect(user.membership_in(another_organization)).to be_nil
    end
  end

  describe 'default values', probedock: { key: 'fee0492b0511', grouped: true } do
    its(:active){ should be(false) }
    its(:technical){ should be(false) }
    its(:roles_mask){ should eq(0) }
  end

  describe 'validations' do
    subject{ described_class.new(active: true) }
    it(nil, probedock: { key: 'jqnu' }){ should have_validations_on(:name, :primary_email, :primary_email_id, :password)}
    it(nil, probedock: { key: '9d5e1ef7c937' }){ should validate_presence_of(:name) }
    it(nil, probedock: { key: '2ea6' }){ should validate_length_of(:name).is_at_most(25) }
    it(nil, probedock: { key: 'r8dq' }){ should allow_value('foo', 'FoO', 'foo-bar', 'Foo-Bar-Baz').for(:name) }
    it(nil, probedock: { key: 'zi5d' }){ should_not allow_value('---', '-foo', 'foo-', '$oo', 'Yee haw').for(:name) }
    it(nil, probedock: { key: '71z7' }){ should validate_presence_of(:primary_email) }
    it(nil, probedock: { key: 'cm6a' }){ should validate_confirmation_of(:password) }
    it(nil, probedock: { key: '3u09' }){ should validate_length_of(:password).is_at_most(512) }
    it(nil, probedock: { key: 'h066' }){ should validate_presence_of(:password) }

    it "should validate that the primary e-mail is among the user's e-mails", probedock: { key: 'rmzp' } do
      user = build(:user)
      user.emails = []
      expect(user).not_to be_valid
    end

    describe 'with an existing user' do
      let(:organization) { create(:organization) }
      let!(:user){ user = create(:user, organization: organization) }
      it(nil, probedock: { key: 'f9be952c7792' }){ should validate_uniqueness_of(:name) }
      it(nil, probedock: { key: 'hxfk' }){ should validate_uniqueness_of(:primary_email_id) }

      it "should validate that the :technical attribute doesn't change", probedock: { key: 'kgha' } do
        user.memberships << build(:membership, user: user, organization: organization)
        user.technical = !user.technical
        expect(user).not_to be_valid
      end
    end

    describe 'a human and a technical user can have the same name in the same organization' do
      let(:organization) { create(:organization) }

      let(:technical_user) do
        technical_user = build(:technical_user, name: 'samename', organization: organization)
        technical_user.memberships << build(:membership, user: technical_user, organization: organization)
        technical_user
      end

      let(:human_user) do
        human_user = build(:user, name: 'samename', organization: organization)
        human_user.memberships << build(:membership, user: human_user, organization: organization)
        human_user
      end

      it 'when the human user already exists', probedock: { key: '97nr' } do
        human_user.save
        expect(technical_user).to be_valid
      end

      it 'when the technical user already exists', probedock: { key: '2r0i' } do
        technical_user.save
        expect(human_user).to be_valid
      end
    end

    describe 'renaming users' do
      let(:organization) { create(:organization) }

      let(:technical_user) do
        technical_user = build(:technical_user, name: 'samename', organization: organization)
        technical_user.memberships << build(:membership, user: technical_user, organization: organization)
        technical_user.save
        technical_user
      end

      let(:human_user) do
        human_user = build(:user, name: 'anothername', organization: organization)
        human_user.memberships << build(:membership, user: human_user, organization: organization)
        human_user.save
        human_user
      end

      it 'is possible when the human user is renamed with the same name of an existing technical user', probedock: { key: 'wofz' } do
        human_user.name = 'samename'
        expect(human_user).to be_valid
      end

      it 'is possible when the technical user is renamed with the same name of an existing human user', probedock: { key: '6zua' } do
        technical_user.name = 'anothername'
        expect(technical_user).to be_valid
      end

      it 'is not possible when the technical user is renamed with the same name of an existing technical user', probedock: { key: '3dio' } do
        another_technical_user = build(:technical_user, name: 'differentname', organization: organization)
        another_technical_user.memberships << build(:membership, user: another_technical_user, organization: organization)
        another_technical_user.save

        technical_user.name = 'differentname'
        expect(technical_user).not_to be_valid
      end

      it 'is not possible when the human user is renamed with the same name of an existing human user', probedock: { key: '66ic' } do
        another_human_user = build(:user, name: 'differentname', organization: organization)
        another_human_user.memberships << build(:membership, user: another_human_user, organization: organization)
        another_human_user.save

        human_user.name = 'differentname'
        expect(human_user).not_to be_valid
      end
    end

    describe 'with an existing technical user' do
      let(:organization) { create(:organization) }
      let!(:first_tech_user) { create(:technical_user, name: 'tech', organization: organization) }
      subject do
        second_tech_user = build(:technical_user, name: 'tech', organization: organization)
        second_tech_user.memberships << build(:membership, user: second_tech_user, organization: organization)
        second_tech_user
      end

      it(nil, probedock: { key: 'iwzr' }) do
        expect(subject).not_to be_valid
        expect(subject.errors[:name].size).to eq(1)
        expect(subject.errors[:name][0]).to eq('must be unique in organization')
      end
    end

    describe 'human normalized name' do
      subject { create(:user, name: 'palpatine') }
      it(nil, probedock: { key: 'vm23' }){ expect(subject.normalized_name).to eq('human||palpatine') }
    end

    describe 'technical normalized name' do
      subject do
        organization = create(:organization, name: 'rebel-alliance')
        tech_user = build(:technical_user, name: 'c3po', organization: organization)
        tech_user.memberships << build(:membership, user: tech_user, organization: organization)
        tech_user.save
        tech_user
      end
      it(nil, probedock: { key: 'km4x' }){ expect(subject.normalized_name).to eq('technical||rebel-alliance||c3po') }
    end

    describe 'for inactive users' do
      subject{ described_class.new(active: false) }
      it(nil, probedock: { key: '703a' }){ should validate_absence_of(:password) }
    end

    describe 'for technical users' do
      subject do
        user = described_class.new technical: true
        allow(user).to receive(:technical_user_is_unique_in_org)
        user
      end
      it(nil, probedock: { key: 'qs8h' }){ should validate_absence_of(:password) }
      it(nil, probedock: { key: 'lakc' }){ should validate_absence_of(:primary_email) }
    end
  end

  describe 'associations' do
    it(nil, probedock: { key: '0zht' }){ should have_associations(:test_keys, :free_test_keys, :test_payloads, :test_results, :memberships, :organizations, :primary_email, :registration, :emails, :test_contributions)}
    it(nil, probedock: { key: '28a9398ebe26' }){ should have_many(:test_keys).dependent(:destroy) }
    it(nil, probedock: { key: 'bc98127d768c' }){ should have_many(:free_test_keys).class_name('TestKey') }
    it(nil, probedock: { key: 'a5dca889075c' }){ should have_many(:test_payloads).with_foreign_key(:runner_id).dependent(:restrict_with_exception) }
    it(nil, probedock: { key: 'o04p' }){ should have_many(:test_results).with_foreign_key(:runner_id).dependent(:restrict_with_exception) }
    it(nil, probedock: { key: 'ydwq' }){ should have_many(:memberships).dependent(:destroy) }
    it(nil, probedock: { key: 'o9o8' }){ should have_many(:organizations).through(:memberships) }
    it(nil, probedock: { key: 'o3tk' }){ should belong_to(:primary_email).class_name('Email').autosave(true) }
    it(nil, probedock: { key: 'i1kp' }){ should have_one(:registration).class_name('UserRegistration') }
    it(nil, probedock: { key: 'q2ma' }){ should have_many(:emails) }
  end

  describe 'database table' do
    it(nil, probedock: { key: 'g40q' }){ should have_db_columns(:id, :primary_email_id, :api_id, :name, :active, :password_digest, :roles_mask, :created_at, :updated_at, :technical, :normalized_name) }
    it(nil, probedock: { key: '48b7f46ea463' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, probedock: { key: 'yi6o' }){ should have_db_column(:api_id).of_type(:string).with_options(null: false, limit: 5) }
    it(nil, probedock: { key: 'edc6773569db' }){ should have_db_column(:name).of_type(:string).with_options(null: false, limit: 25) }
    it(nil, probedock: { key: '9p59' }){ should have_db_column(:password_digest).of_type(:string).with_options(null: true) }
    it(nil, probedock: { key: 'f26x' }){ should have_db_column(:primary_email_id).of_type(:integer).with_options(null: true) }
    it(nil, probedock: { key: '6e6d67322510' }){ should have_db_column(:roles_mask).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, probedock: { key: 'ab9173bec164' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: 'bhcb' }){ should have_db_column(:technical).of_type(:boolean).with_options(null: false, default: false) }
    it(nil, probedock: { key: '19faaeaea1cf' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'd4502778d426' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, probedock: { key: 'd7vv' }){ should have_db_index(:api_id).unique(true) }
  end
end

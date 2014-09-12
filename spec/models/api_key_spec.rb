# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
require 'spec_helper'

describe ApiKey do

  context "when created" do
    subject{ create :api_key }

    it "should have a well-formatted identifier", rox: { key: '770a87dc4525' } do
      expect(subject.identifier).to match(/\A[a-z0-9]{20}\Z/i)
    end

    it "should have a well-formated shared secret", rox: { key: 'dac9093b51f3' } do
      expect(subject.shared_secret).to match(/\A[a-z0-9]{50}\Z/i)
    end
  end

  context ".authenticated" do

    it "should find an active key", rox: { key: 'c6ee2ca39b6c' } do
      key = create :api_key
      expect(ApiKey.authenticated(key.identifier, key.shared_secret).first).to eq(key)
    end

    it "should not find an inactive key", rox: { key: 'd10128e718ce' } do
      key = create :api_key, active: false
      expect(ApiKey.authenticated(key.identifier, key.shared_secret).first).to be_blank
    end

    it "should not find a key belonging to an inactive user", rox: { key: '00127fea7b9a' } do
      user = create :user, active: false
      
      key = create :api_key, active: true, user: user
      expect(ApiKey.authenticated(key.identifier, key.shared_secret).first).to be_blank

      key = create :api_key, active: false, user: user
      expect(ApiKey.authenticated(key.identifier, key.shared_secret).first).to be_blank
    end
  end

  context "#to_param" do
    subject{ create :api_key }

    it "should return the identifier", rox: { key: 'cec8e660cbfd' } do
      expect(subject.to_param).to eq(subject.identifier)
    end
  end

  context "#find_by_identifier" do
    
    it "should find an api key by its identifier", rox: { key: '26ee140c895a' } do
      key = create :api_key
      expect(ApiKey.find_by_identifier(key.identifier).first).to eq(key)
    end
  end

  context ".create_for_user" do

    it "should create an active key for the user", rox: { key: '36658a00d2e6' } do

      user = create :user
      expect(user.api_keys).to have(1).item

      key = ApiKey.create_for_user user
      expect(key.active).to be(true)

      user.reload
      expect(user.api_keys).to have(2).items
      expect(user.api_keys).to include(key)
    end
  end

  context "validations" do
    it(nil, rox: { key: 'eb4c286b4490' }){ should validate_presence_of(:user) }
    it(nil, rox: { key: '9b4b6b39644a' }){ should allow_value(true, false).for(:active) }
  end

  context "associations" do
    it(nil, rox: { key: '111fce4a297c' }){ should belong_to(:user) }
  end

  context "database table" do
    it(nil, rox: { key: '686cecc7cebd' }){ should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: '118491b34cb4' }){ should have_db_column(:identifier).of_type(:string).with_options(null: false, limit: 20) }
    it(nil, rox: { key: '212a7072b8ba' }){ should have_db_column(:shared_secret).of_type(:string).with_options(null: false, limit: 50) }
    it(nil, rox: { key: '424da102daae' }){ should have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
    it(nil, rox: { key: '080e121c1011' }){ should have_db_column(:usage_count).of_type(:integer).with_options(null: false, default: 0) }
    it(nil, rox: { key: '2f7982559a25' }){ should have_db_column(:last_used_at).of_type(:datetime).with_options(null: true) }
    it(nil, rox: { key: '59297c78364c' }){ should have_db_column(:user_id).of_type(:integer).with_options(null: false) }
    it(nil, rox: { key: 'abc346418ece' }){ should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'e9c3b95f2d14' }){ should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it(nil, rox: { key: 'ccbe22fa0737' }){ should have_db_index(:identifier).unique(true) }
  end
end

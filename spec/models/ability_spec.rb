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

describe Ability, rox: { tags: :unit } do

  let(:user){ nil }
  subject{ Ability.new user }

  context "for a guest" do

    it(nil, rox: { key: '1c5df1b1e8ca' }){ should_not be_able_to(:manage, :account) }
  end

  context "for a registered user" do
    let(:user){ create :user }
    let(:other_user){ create :other_user }

    it(nil, rox: { key: 'bf64657a64fc' }){ should be_able_to(:manage, :account) }

    it('should be able to manage an api key owned by the user', rox: { key: '3d4647681786' }){ should be_able_to(:manage, ApiKey.new.tap{ |a| a.user_id = user.id }) }

    it('should not be able to manage an api key owned by another user', rox: { key: '2be7d2a55b6b' }){ should_not be_able_to(:manage, ApiKey.new.tap{ |a| a.user_id = other_user.id }) }
  end

  context "for an administrator" do
    let(:user){ create :admin }

    it(nil, rox: { key: 'a4627a35007d' }){ should be_able_to(:manage, :all) }
  end
end

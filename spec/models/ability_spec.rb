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

describe Ability, probe_dock: { tags: :unit } do

  let(:user){ nil }
  subject{ Ability.new user }

  context "for a guest" do

    it(nil, probe_dock: { key: '1c5df1b1e8ca' }){ should_not be_able_to(:manage, :account) }
  end

  context "for a registered user" do
    let(:user){ create :user }
    let(:other_user){ create :other_user }

    it(nil, probe_dock: { key: 'bf64657a64fc' }){ should be_able_to(:manage, :account) }

    it('should be able to manage an api key owned by the user', probe_dock: { key: '3d4647681786' }){ should be_able_to(:manage, ApiKey.new.tap{ |a| a.user_id = user.id }) }

    it('should not be able to manage an api key owned by another user', probe_dock: { key: '2be7d2a55b6b' }){ should_not be_able_to(:manage, ApiKey.new.tap{ |a| a.user_id = other_user.id }) }
  end

  context "for an administrator" do
    let(:user){ create :admin }

    it(nil, probe_dock: { key: 'a4627a35007d' }){ should be_able_to(:manage, :all) }
  end
end

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

describe ApplicationHelper do

  describe "#meta_session" do

    it "should generate meta data for the current user", rox: { key: '56d9618d23c8' } do
      helper.stub current_user: user = create(:user)
      expect(helper.meta_session).to eq(cache: cache_key(user))
    end

    it "should generate meta data for an admin user", rox: { key: 'fa2727d792bf' } do
      helper.stub current_user: user = create(:admin)
      expect(helper.meta_session).to eq(admin: true, cache: cache_key(user))
    end

    def cache_key user
      Digest::SHA1.hexdigest "#{user.created_at.to_r}-#{user.id}"
    end
  end

  describe "#meta_maintenance" do

    it "should generate meta data for the maintenance mode", rox: { key: '2c169da2c7e9' } do
      @maintenance = { since: now = Time.now }
      expect(helper.meta_maintenance).to eq(since: now.to_i * 1000)
    end
  end
end

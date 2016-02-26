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

RSpec.describe ProbeDock::TestKeysApi do
  let(:organization){ create :organization }
  let(:user){ create :org_admin, organization: organization }

  describe 'GET /api/test-keys' do
    it 'should return an empty array when no test key exists', probedock: { key: '3vgo' } do
      api_get '/api/test-keys', query: { organizationId: organization.api_id }, user: user
      expect(response).to be_empty_json_array
    end
  end
end

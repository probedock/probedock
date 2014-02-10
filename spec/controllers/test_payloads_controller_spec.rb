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

describe TestPayloadsController do
  let(:user){ create :user }

  it "should not authorize unauthenticated users", rox: { key: '752a7db0dc8b' } do
    get :show, id: 42
    expect(response).to redirect_to(new_user_session_path)
  end

  describe "#show" do
    let(:test_payload){ create :test_payload, user: user, contents: MultiJson.dump(foo: 'bar') }
    before(:each){ sign_in user }

    it "should serialize a test payload", rox: { key: 'bce644d4907e' } do
      get :show, id: test_payload.id
      expect(response.status).to eq(200)
      expect(MultiJson.load(response.body)).to eq(MultiJson.load(MultiJson.dump(test_payload.serializable_hash)))
    end
  end
end

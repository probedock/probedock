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

RSpec.describe JSON::JWT do
  let(:user){ create :user }

  # This test is a failsafe to detect a potential future problem with our JWT authentication tokens.
  # New tokens are generated with no "exp" claim (expiration date), as we plan to manually handle
  # expiration in most cases. However, some of the tokens generated earlier do have one. The current
  # version of the json-jwt gem we use does not automatically check this date but future versions
  # might (as it is part of the JWT specification).
  #
  # If this test fails, it might mean that the json-jwt library now automatically raises an error if
  # the expiration date is in the past. In that case, all old authentication should be re-issued
  # before pushing the upgrade to production.
  #
  # https://github.com/nov/json-jwt
  it "should not raise an error if a token is expired" do

    claims = {
      iss: user.api_id,
      exp: 1.year.ago,
      nbf: 2.years.ago
    }

    token = JSON::JWT.new(claims).sign(Rails.application.secrets.jwt_secret, 'HS512').to_s

    decoded_claims = nil
    expect do
      decoded_claims = JSON::JWT.decode(token, Rails.application.secrets.jwt_secret)
    end.not_to raise_error

    expect(decoded_claims).to eq(claims.stringify_keys)
  end
end

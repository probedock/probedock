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

describe "API payload controller" do
  include MaintenanceHelpers
  let(:user){ create :user }
  let(:sample_payload){ {} }

  before :each do
    ResqueSpec.reset!
  end

  it "should return a 503 response when in maintenance mode", rox: { key: '1537ac0ebada' } do
    set_maintenance_mode
    post_api_payload sample_payload.to_json, user
    expect(response.status).to eq(503)
    expect(ProcessNextTestPayloadJob).to have_queue_size_of(0)
  end
end

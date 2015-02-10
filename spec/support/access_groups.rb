# Copyright (c) 2015 42 inside
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
shared_examples_for "an admin resource" do |op|

  it "should not authorize unauthenticated users" do
    instance_eval &op
    expect(response).to redirect_to(new_user_session_path)
  end

  describe "when logged in" do
    before(:each){ sign_in user }

    it "should not authorize normal users" do
      expect{ instance_eval &op }.to raise_error(CanCan::AccessDenied)
    end
  end
end

shared_examples_for "an admin API resource" do |op|

  it "should not authorize unauthenticated users" do
    instance_eval &op
    expect(response.status).to eq(401)
  end

  describe "when logged in" do
    before(:each){ sign_in user }

    it "should not authorize normal users" do
      instance_eval &op
      expect(response.status).to eq(403)
    end
  end
end

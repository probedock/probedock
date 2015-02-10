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

RSpec.describe PurgesController, type: :controller do
  let(:user){ create :user }

  describe "#index" do

    describe "access", rox: { key: 'd9bf9a3d6f76', grouped: true } do
      it_should_behave_like "an admin resource", ->(*args){ get :index }
    end

    describe "when logged in as administrator" do
      let(:user){ create :admin_user }
      before(:each){ sign_in user }
      before(:each){ get :index }
      subject{ assigns }

      it "should set the window title", rox: { key: 'cecebcc91976' } do
        expect(subject[:window_title]).to eq([ t('common.title'), PurgeAction.model_name.human.pluralize.titleize ])
      end
    end
  end
end

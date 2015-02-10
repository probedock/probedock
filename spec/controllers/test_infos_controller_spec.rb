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
require 'spec_helper'

describe TestInfosController, probe_dock: { tags: :integration } do
  let(:user){ create :user }
  let(:author){ create :other_user }
  let(:project){ create :project }
  before(:each){ sign_in user }

  describe "#show" do
    let(:test){ create :test, key: create(:key, user: user) }

    it "should redirect to the correct page when the id is only the test key and one test matches", probe_dock: { key: 'adb58980cefd' } do
      get :show, id: test.key.key, locale: I18n.default_locale
      expect(subject).to redirect_to(test)
    end
  end
end

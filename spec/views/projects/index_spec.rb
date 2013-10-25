# Copyright (c) 2012-2013 Lotaris SA
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

describe 'projects/index', rox: { tags: :unit } do
  subject{ render; rendered }

  it "should not inject the projectEditor module for a non-admin user", rox: { key: 'dc6b60fe4da4' } do
    expect(subject).not_to have_selector('div', :'data-module' => 'projectEditor')
  end

  it "should inject the projectsTable module", rox: { key: 'a91bb7a51202' } do
    subject.should have_selector('div', :'data-module' => 'projectsTable')
  end

  context "with a user who can manage projects" do
    fake_controller_current_ability :manage, Project

    it "should inject the projectEditor module", rox: { key: '9283bb0f2c81' } do
      expect(subject).to have_selector('div', :'data-module' => 'projectEditor')
    end
  end
end

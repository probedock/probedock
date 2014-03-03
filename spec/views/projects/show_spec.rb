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

describe 'projects/show', rox: { tags: :unit } do

  let(:project){ create :project }
  subject{ render; rendered }
  let(:page) { Capybara::Node::Simple.new(subject) }

  before :each do
    assign :project, project
  end

  it "should not inject the projectEditor module for a non-admin user", rox: { key: '327704aec0ac' } do
    expect(subject).not_to have_selector('div[data-module="projectEditor"]')
  end

  it "should inject the testsTable module", rox: { key: '5e5708265080' } do
    assign :tests_table_config, tests_table_config = { tests: 'table config' }
    sel = 'div[data-module="testsTable"]'
    expect(subject).to have_selector(sel)
    expect(find(sel)['data-config']).to eq(tests_table_config.to_json)
  end

  context "with a user who can manage projects" do
    fake_controller_current_ability :manage, Project

    it "should inject the projectEditor module", rox: { key: '68f6e5519c49' } do
      assign :project_editor_config, project_editor_config = { project: 'editor config' }
      sel = 'div[data-module="projectEditor"]'
      expect(subject).to have_selector(sel)
      expect(find(sel)['data-config']).to eq(project_editor_config.to_json)
    end
  end
end

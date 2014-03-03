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

describe ProjectsController, rox: { tags: :unit } do
  let(:user){ create :user }
  before(:each){ sign_in user }
  subject{ assigns }

  context "#index" do
    before(:each){ get :index, locale: I18n.default_locale }

    it "should set the window title", rox: { key: '23fcc4f89597' } do
      expect(subject[:window_title]).to eq([ t('.common.title'), Project.model_name.human.pluralize.titleize ])
    end
  end

  context "#show" do
    let(:project){ create :project }
    before(:each){ get :show, id: project.url_token, locale: I18n.default_locale }

    it "should set the window title", rox: { key: '3443f67737f5' } do
      expect(subject[:window_title]).to eq([ t('.common.title'), Project.model_name.human.pluralize.titleize, project.name ])
    end

    it "should set the project editor configuration", rox: { key: '89328cd513be' } do
      expect(subject[:project_editor_config]).to eq({ model: ProjectRepresenter.new(project).serializable_hash })
    end

    it "should set the test search configuration", rox: { key: 'd068433ab1b7' } do
      expect(subject[:tests_table_config][:search]).to eq(TestSearch.config({}, except: [ :projects, :current ]))
    end
  end
end

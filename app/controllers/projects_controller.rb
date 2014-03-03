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
class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  before_filter{ window_title << Project.model_name.human.pluralize.titleize }

  load_resource find_by: :url_token, only: [ :show, :tests_page ]

  def show
    window_title << @project.name
    @project_editor_config = { model: ProjectRepresenter.new(@project).serializable_hash }
    @tests_table_config = {
      uriTemplateParams: { 'projects[]' => [ @project.name ] },
      search: TestSearch.config(params, except: [ :projects, :current ])
    }
  end
end

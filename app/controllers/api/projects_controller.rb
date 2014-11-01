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
class Api::ProjectsController < Api::ApiController
  #before_filter :check_maintenance, only: [ :create, :update ]
  #before_filter(except: [ :index ]){ authorize! :manage, Project }

  #load_resource find_by: :api_id
  #skip_load_resource except: [ :show, :update ]

  def index
    render json: Project.tableling.process(params)
  end

  def show
    render_api ProjectRepresenter.new(@project)
  end

  def create
    @project = Project.new parse_json_project
    if @project.errors.empty? and @project.save
      render json: @project.to_json
    else
      render_api_model_errors @project
    end
  end

  def update
    if @project.errors.empty? and @project.update_attributes parse_json_project
      render_api ProjectRepresenter.new(@project)
    else
      render_api_model_errors @project
    end
  end

  private

  def parse_json_project
    parse_json_model 'name'
  end
end

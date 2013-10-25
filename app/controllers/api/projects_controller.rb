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

class Api::ProjectsController < Api::ApiController
  before_filter(except: [ :index ]){ authorize! :manage, Project }

  def index
    render_api Project.tableling.process(params)
  end

  def create
    @project = Project.new parse_json_project
    if @project.errors.empty? and @project.save
      render_api ProjectRepresenter.new(@project)
    else
      render_api_model_errors @project
    end
  end

  def update
    @project = Project.where(api_id: params[:id].to_s).first
    if @project.errors.empty? and @project.update_attributes parse_json_project
      render_api ProjectRepresenter.new(@project)
    else
      render_api_model_errors @project
    end
  end

  private

  def parse_json_project
    parse_json_model 'name', 'urlToken'
  end
end

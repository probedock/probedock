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
class Api::TestsController < Api::ApiController
  before_filter :check_maintenance, only: [ :create, :update ]

  def index
    render_api TestInfo.tableling.process(params.merge(TestSearch.options(params[:search])))
  end

  def show
    @test_info = TestInfo.find_by_project_and_key!(params[:id]).first!
    render_api TestInfoRepresenter.new @test_info
  end
end

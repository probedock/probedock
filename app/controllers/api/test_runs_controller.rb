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
class Api::TestRunsController < Api::ApiController
  load_resource
  skip_load_resource except: [ :show ]

  def index

    if params.key? :latest
      cache = LatestTestRunsData.compute
      render_api cache if cache_stale? cache
      return
    end

    render_api TestRun.tableling.process(TestRunSearch.options(params))
  end

  def show
    render_api TestRunRepresenter.new(@test_run)
  end
end

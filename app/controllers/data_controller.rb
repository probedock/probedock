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
class DataController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :load_links

  def status
    render json: StatusData.compute
  end

  def latest_test_runs
    cache = LatestTestRunsData.compute
    render json: cache.contents.first(params.key?(:n) ? params[:n].to_i : 8) if cache_stale? cache
  end

  def current_test_metrics
    render json: CurrentTestMetricsData.compute
  end

  def test_counters

    if request.post? && !TestCounter.recompute!
      return render text: 'Already recomputing', status: 503
    end

    render json: TestCountersData.compute
  end
end

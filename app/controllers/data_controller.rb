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
class DataController < ApplicationController
  skip_before_filter :load_links
  before_filter :authenticate_user!
  before_filter(only: [ :test_counters ]){ authorize! :manage, :settings }

  def status
    render json: StatusData.compute
  end

  def general
    render json: GeneralData.compute(params)
  end

  def current_test_metrics
    render json: CurrentTestMetricsData.compute
  end

  def test_counters

    if request.post?
      return render text: 'Must be in maintenance mode', status: 503 unless @maintenance
      return render text: 'Already recomputing', status: 503 if !TestCounter.recompute!
    end

    render json: TestCountersData.compute
  end
end

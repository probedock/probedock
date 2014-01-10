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
class SettingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter{ authorize! :manage, :settings }
  before_filter :check_maintenance, only: [ :update ]

  def show
    respond_to do |format|

      format.html do
        window_title << t('settings.show.title')
        @status_data = StatusData.compute
        @test_counters_config = { data: TestCountersData.compute }
      end

      format.json do
        render json: Settings::App.get
      end
    end
  end

  def update
    settings = Settings::App.get
    settings.update_attributes setting_params
    render json: settings.tap(&:reload)
  end

  private

  def setting_params
    params.require(:setting).permit(:ticketing_system_url, :reports_cache_size, :tag_cloud_size, :test_outdated_days)
  end
end

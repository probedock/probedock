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
class HomeController < ApplicationController
  before_filter :authenticate_user!, except: [ :ping ]
  skip_before_filter :load_links, only: [ :index, :ping ]

  def root
    redirect_to home_path
  end

  def index

    # Load all caches at the same time to avoid separate commands being sent to Redis.
    caches = Settings.cache, TagsData.cloud, TestsData.compute, LatestTestRunsData.compute, LatestProjectsData.compute
    caches << cached_links if user_signed_in?
    cached = JsonCache.get *caches

    @tag_cloud = home_tag_cloud cached[1].contents, cached[0]
    @tests_data = cached[2]
    @latest_test_runs_data = cached[3].contents.first(8) # TODO: allow to customize default number of latest runs on home page
    @latest_projects = cached[4].contents
    @links = cached[5].try :contents
    @current_test_metrics_config = CurrentTestMetricsData.compute
    @status_data = StatusData.compute
  end

  def ping
    render text: "ROX Center v#{ROXCenter::Application::VERSION} #{Rails.env}"
  end

  # TODO: move status routes to data controller
  def status
    window_title << t('home.status.title')
    @status = statuses
  end

  def api_status
    render :json => statuses(true)
  end

  def app_status
    cache = AppData.compute
    render :json => cache if cache_stale? cache
  end

  def db_status
    cache = DbData.compute
    render :json => cache if cache_stale? cache
  end

  def jobs_status
    render :json => JobsData.compute
  end

  private

  def home_tag_cloud contents, cached_settings
    size = Settings.app(cached_settings).tag_cloud_size
    { size: size, total: contents.length, cloud: TagsData.sized_cloud(contents, size) }
  end

  def statuses api = false
    {
      app: AppData.compute.contents,
      db: DbData.compute.contents,
      jobs: JobsData.compute,
      tests: TestsData.compute.contents
    }.tap do |h|
      h[:admin] = true if !api and current_user.admin?
    end
  end
end

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
class HomeController < ApplicationController
  before_filter :authenticate_user!, except: [ :ping ]
  before_filter :load_status_data, only: [ :status ]
  before_filter(only: [ :maintenance ]){ authorize! :manage, :settings }
  skip_before_filter :load_links, only: [ :index, :ping ]

  def index

    # Load all caches at the same time to avoid separate commands being sent to Redis.
    caches = Settings.cache, TagsData.cloud, LatestTestRunsData.compute, LatestProjectsData.compute
    caches << cached_links if user_signed_in?
    cached = JsonCache.get *caches

    settings = Settings.app cached[0]

    @tag_cloud = home_tag_cloud cached[1].contents, settings
    @latest_test_runs_data = cached[2].contents.first(8) # TODO: allow to customize default number of latest runs on home page
    @latest_projects = cached[3].contents
    @links = cached[4].try :contents
    @current_test_metrics_config = CurrentTestMetricsData.compute

    # TODO: find a way to do this in the $redis.multi done by JsonCache.get above
    # TODO: include load_maintenance in the $redis.multi done by JsonCache.get above
    @status_data = StatusData.compute
    @general_data = GeneralData.compute settings: settings, count: { tests: true, runs: true }, tests: true
  end

  def status
    window_title << t('home.status.title')
    @general_data = GeneralData.compute environment: true, jobs: true, count: true, db: true
  end

  def ping
    render text: "ROX Center v#{ROXCenter::Application::VERSION} #{Rails.env}"
  end

  def maintenance
    if request.post?
      time = $redis.multi do
        $redis.setnx :maintenance, Time.now.to_r.to_s
        $redis.get :maintenance
      end.last
      render json: { since: Time.at(Rational(time)).to_i * 1000 }
    else
      $redis.del :maintenance
      head :no_content
    end
  end

  private

  def home_tag_cloud contents, settings
    size = settings.tag_cloud_size
    { size: size, total: contents.length, cloud: TagsData.sized_cloud(contents, size) }
  end
end

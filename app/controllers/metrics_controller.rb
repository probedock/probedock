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
class MetricsController < ApplicationController
  before_filter :authenticate_user!

  def index

    window_title << t('metrics.index.title')

    customs = {
      author: { link: user_path('000'), label: :name }
    }

    %w(author project category).each do |breakdown|

      custom = customs[breakdown.to_sym] || {}

      config = {
        dimension: breakdown,
        path: send("#{breakdown}_breakdown_legacy_api_metrics_path"),
        link: custom[:link] || test_infos_path({ breakdown.pluralize => [ '000' ] }),
        label: custom[:label]
      }.select{ |k,v| v.present? }

      instance_variable_set "@#{breakdown}_breakdown_config", config
    end
  end

  def category_breakdown
    render json: TestInfo.count_by_category
  end

  def project_breakdown
    render json: TestInfo.count_by_project
  end

  def author_breakdown
    render json: TestInfo.count_by_author.collect{ |c| c.merge author: c[:author].to_client_hash }
  end
end

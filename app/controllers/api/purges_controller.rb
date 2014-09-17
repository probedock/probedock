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
class Api::PurgesController < Api::ApiController
  before_filter{ authorize! :manage, PurgeAction }

  def index
    if params[:info].present?

      purges = PurgeAction::DATA_TYPES.collect do |type|
        PurgeAction.last_for(type).first || PurgeAction.new(data_type: type)
      end

      render_api PurgeActionsRepresenter.new(OpenStruct.new(data: purges, total: purges.length), info: true)
      return
    end

    render_api PurgeAction.tableling.process(params)
  end

  def create
    @purge = PurgeAction.new parse_json_purge
    if @purge.errors.empty? and @purge.save
      render_api PurgeActionRepresenter.new(@purge)
    else
      render_api_model_errors @purge
    end
  end

  private

  def parse_json_purge
    parse_json_model 'dataType'
  end
end

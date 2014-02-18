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
class PurgesController < ApplicationController
  PURGES = [ PurgeTagsJob, PurgeTicketsJob, PurgeTestPayloadsJob ]
  before_filter :authenticate_user!
  before_filter{ authorize! :manage, :app }
  before_filter :check_maintenance, only: [ :purge, :purge_all ]

  def index
    render json: PURGES.collect(&:purge_info)
  end

  def purge

    purge = PURGES.find{ |p| p.purge_id.to_s == params[:id].to_s }
    raise ActiveRecord::RecordNotFound unless purge

    Resque.enqueue purge
    head :no_content
  end

  def purge_all
    PURGES.each{ |p| Resque.enqueue p }
    head :no_content
  end
end

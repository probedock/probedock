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
require 'exceptions'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  #before_filter :load_maintenance

  private

  def media_type name
    Mime::Type.lookup_by_extension(name).to_s
  end

  def set_locale
    I18n.locale = 'en'
  end

  def load_maintenance
    if value = $redis.get(:maintenance)
      @maintenance = { since: Time.at(Rational(value)) }
    end
  end

  def render_maintenance
    render json: { since: @maintenance[:since].to_ms }, status: :service_unavailable
  end

  def check_maintenance
    render_maintenance if @maintenance
  end

  def cache_stale? cache
    cached_object = cache.respond_to?(:get) ? cache.get : cache
    stale? last_modified: cached_object.updated_at.utc, etag: cached_object.etag
  end
end

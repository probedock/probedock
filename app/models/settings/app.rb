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

class Settings::App < ActiveRecord::Base
  self.table_name = 'app_settings'

  after_save :clear_cache

  strip_attributes
  validates :ticketing_system_url, length: { maximum: 255 }
  validates :reports_cache_size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :tag_cloud_size, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :test_outdated_days, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  def self.get
    first
  end

  def serializable_hash options = {}
    {
      ticketing_system_url: ticketing_system_url,
      reports_cache_size: reports_cache_size,
      tag_cloud_size: tag_cloud_size,
      test_outdated_days: test_outdated_days
    }.select{ |k,v| v.present? }
  end

  private

  def clear_cache
    JsonCache.clear 'settings:app', 'tests_status'
  end
end

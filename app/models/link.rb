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
class Link < ActiveRecord::Base
  after_save :clear_cache
  after_destroy :clear_cache

  strip_attributes
  validates :name, presence: true, length: { maximum: 50 }
  validates :url, presence: true, length: { maximum: 255 }

  def to_client_hash options = {}
    { id: id, name: name, url: url }
  end

  private

  def clear_cache
    JsonCache.clear :links
  end
end

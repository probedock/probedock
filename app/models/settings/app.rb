# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
class Settings::App < ActiveRecord::Base
  self.table_name = 'app_settings'

  strip_attributes
  # TODO: add max time during which a report remains editable
  validates :user_registration_enabled, inclusion: { in: [ true, false ] }

  def self.get
    first
  end

  def serializable_hash options = {}
    DATA_ATTRS.inject({}) do |memo,attr|
      memo[attr] = send attr unless send(attr).nil?
      memo
    end
  end

  private

  DATA_ATTRS = [ :user_registration_enabled ]
end

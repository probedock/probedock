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
class TestDeprecation < ActiveRecord::Base

  belongs_to :test_info
  belongs_to :test_result
  belongs_to :user

  attr_accessible # none

  validates :user, presence: true
  validates :test_info, presence: true
  validates :test_result, presence: true
  validates :deprecated, inclusion: { in: [ true, false ] }
end

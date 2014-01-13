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
class Settings::User < ActiveRecord::Base
  self.table_name = 'user_settings'

  belongs_to :last_test_key_project, class_name: 'Project'

  validates :last_test_key_number, numericality: { only_integer: true, greater_than: 0, allow_blank: true }

  def last_test_key_project_api_id
    last_test_key_project.try :api_id
  end
end

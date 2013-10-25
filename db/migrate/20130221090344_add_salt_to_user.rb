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
class AddSaltToUser < ActiveRecord::Migration

  def up
    add_column :users, :salt, :string
    User.reset_column_information
    User.select('id').all.each{ |u| u.update_attribute :salt, SecureRandom.hex(128)[0, 255] }
    change_column :users, :salt, :string, :null => false
  end

  def down
    remove_column :users, :salt
  end
end

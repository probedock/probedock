# Copyright (c) 2015 42 inside
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
class CreateTestValues < ActiveRecord::Migration

  def change
    create_table :test_values do |t|
      t.string :name, :null => false, :limit => 50
      t.string :contents, :null => false
      t.references :test_info, :null => false
    end

    add_index :test_values, [ :test_info_id, :name ], :unique => true
    add_foreign_key :test_values, :test_infos
  end
end

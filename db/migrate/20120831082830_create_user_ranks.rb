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
class CreateUserRanks < ActiveRecord::Migration
  def change
    create_table :user_ranks do |t|

      t.references :user, :null => false
      t.references :ranking, :null => false
      t.integer :value, :null => false

      t.timestamps
    end

    add_index :user_ranks, [ :user_id, :ranking_id, :created_at ], :unique => true
  end
end

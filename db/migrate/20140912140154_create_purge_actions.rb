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
class CreatePurgeActions < ActiveRecord::Migration
  def change
    create_table :purge_actions do |t|
      t.string :data_type, null: false, limit: 20
      t.integer :number_purged, null: false, default: 0
      t.integer :remaining_jobs, null: false, default: 1
      t.string :description
      t.datetime :completed_at
      t.timestamps null: false
    end
  end
end

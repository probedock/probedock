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

class CreateTestCounters < ActiveRecord::Migration

  def change

    create_table :test_counters do |t|

      t.string :timezone, null: false, limit: 30
      t.datetime :timestamp, null: false
      t.integer :mask, null: false
      t.string :unique_token, null: false, limit: 100

      t.integer :user_id
      t.foreign_key :users
      t.integer :category_id
      t.foreign_key :categories
      t.integer :project_id
      t.foreign_key :projects

      t.integer :written_counter, null: false, default: 0
      t.integer :run_counter, null: false, default: 0

      t.integer :total_written
      t.integer :total_run
    end

    add_index :test_counters, :unique_token, unique: true
    add_index :test_counters, [ :timezone, :timestamp, :mask ]
  end
end

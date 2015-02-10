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
class AddGlobalMetrics < ActiveRecord::Migration

  class Measure < ActiveRecord::Base; end

  def up

    remove_foreign_key :measures, :metric
    remove_foreign_key :measures, :user
    remove_index :measures, [ :user_id, :metric_id, :created_at ]
    add_foreign_key :measures, :metrics
    add_foreign_key :measures, :users

    change_column :measures, :user_id, :integer, :null => true
    add_column :measures, :started_at, :datetime
    Measure.reset_column_information
    Measure.update_all 'started_at = created_at'
    change_column :measures, :started_at, :datetime, :null => false
  end

  def down
    remove_column :measures, :started_at
    change_column :measures, :user_id, :integer, :null => false
    add_index :measures, [ :user_id, :metric_id, :created_at ]
  end
end

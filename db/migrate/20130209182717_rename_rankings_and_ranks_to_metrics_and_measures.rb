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
class RenameRankingsAndRanksToMetricsAndMeasures < ActiveRecord::Migration

  def up

    drop_table :ranks

    rename_table :rankings, :metrics
    change_column :metrics, :name, :string, :null => false, :limit => 32
    add_index :metrics, :name, :unique => true

    remove_foreign_key :user_ranks, :ranking
    remove_foreign_key :user_ranks, :user
    remove_index :user_ranks, [ :user_id, :ranking_id, :created_at ]
    rename_table :user_ranks, :measures
    rename_column :measures, :ranking_id, :metric_id
    remove_index :measures, name: 'user_ranks_ranking_id_fk'
    add_foreign_key :measures, :metrics, column: 'metric_id'
    add_foreign_key :measures, :users
    add_index :measures, [ :user_id, :metric_id, :created_at ], :unique => true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

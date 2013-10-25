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
class RenameTestToTestInfo < ActiveRecord::Migration
  def up
    rename_table :tests, :test_infos
    rename_column :test_results, :test_id, :test_info_id
    remove_index :tags_tests, [ :tag_id, :test_id ]
    rename_table :tags_tests, :tags_test_infos
    rename_column :tags_test_infos, :test_id, :test_info_id
    add_index :tags_test_infos, [ :tag_id, :test_info_id ], :unique => true
  end

  def down
    remove_index :tags_test_infos, [ :tag_id, :test_info_id ]
    rename_column :tags_test_infos, :test_info_id, :test_id
    rename_table :tags_test_infos, :tags_tests
    add_index :tags_tests, [ :tag_id, :test_id ]
    rename_column :test_results, :test_info_id, :test_id
    rename_table :test_infos, :tests
  end
end

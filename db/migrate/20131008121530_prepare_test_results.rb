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
class PrepareTestResults < ActiveRecord::Migration

  def up
    change_table :test_results, bulk: true do |t|
      
      # for create_projects migration
      t.column :project_version_id, :integer

      # for duplicate_result_data migration
      t.column :new_test, :boolean, null: false, default: false
      t.column :category_id, :integer
      t.foreign_key :categories
      t.column :previous_category_id, :integer
      t.foreign_key :categories, column: :previous_category_id
      t.column :previous_passed, :boolean
      t.column :previous_active, :boolean
      t.column :deprecated, :boolean, null: false, default: false
    end
  end

  def down
    change_table :test_results, bulk: true do |t|

      # for create_projects migration
      t.column :version, :string, null: false
      t.remove :project_version_id

      # for duplicate_result_data migration
      t.remove :new_test, :category_id, :previous_category_id, :previous_passed, :previous_active, :deprecated
    end
  end
end

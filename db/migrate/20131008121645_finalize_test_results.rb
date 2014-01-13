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
class FinalizeTestResults < ActiveRecord::Migration

  def up
    change_table :test_results, bulk: true do |t|

      # for create_projects migration
      t.remove :version
      t.change :project_version_id, :integer, null: false
      t.foreign_key :project_versions
    end
  end

  def down
    change_table :test_results, bulk: true do |t|

      # for create_projects migration
      t.column :version, :string
      t.remove_foreign_key :project_versions
    end
  end
end

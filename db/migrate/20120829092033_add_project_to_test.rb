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
class AddProjectToTest < ActiveRecord::Migration
  def up
    # for some reason, SQLite doesn't want us to add a non-null column with
    # no default value, so we have to do it in two operations
    add_column :tests, :project, :string
    change_column :tests, :project, :string, :null => false
  end

  def down
    remove_column :tests, :project
  end
end

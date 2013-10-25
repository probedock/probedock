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
class AddDeprecatedAtToTests < ActiveRecord::Migration

  def up

    add_column :test_infos, :deprecated_at, :datetime

    say_with_time "setting deprecated_at for deprecated tests" do
      TestInfo.where(deprecated: true).update_all 'deprecated_at = updated_at'
    end

    remove_column :test_infos, :deprecated
  end

  def down

    add_column :test_infos, :deprecated, :boolean, null: false, default: false

    say_with_time "setting deprecated for deprecated tests" do
      TestInfo.where('deprecated_at IS NOT NULL').update_all deprecated: true
    end

    remove_column :test_infos, :deprecated_at
  end
end

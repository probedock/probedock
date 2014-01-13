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
class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :ranks, :rankings
    add_foreign_key :tags_test_infos, :tags
    add_foreign_key :tags_test_infos, :test_infos
    add_foreign_key :test_infos, :users, column: 'author_id'
    add_foreign_key :test_infos, :test_keys, column: 'key_id'
    add_foreign_key :test_keys, :users
    add_foreign_key :test_results, :test_infos
    add_foreign_key :test_results, :users, column: 'runner_id'
    add_foreign_key :user_ranks, :users
    add_foreign_key :user_ranks, :rankings
  end
end

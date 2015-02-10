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
class AddLastRunIdToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  class TestRun < ActiveRecord::Base
  end

  def up

    add_column :users, :last_run_id, :integer
    add_foreign_key :users, :test_runs, column: :last_run_id
    User.reset_column_information

    users = User.select('id').all
    say_with_time "setting last run ID for #{users.length} users" do
      users.each do |u|
        last_run = TestRun.select('id').where(runner_id: u.id).order('ended_at DESC').limit(1).first
        u.update_attribute :last_run_id, last_run.id if last_run.present?
      end
    end
  end

  def down
    remove_foreign_key :users, :last_run
    remove_column :users, :last_run_id
  end
end

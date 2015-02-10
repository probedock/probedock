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
class AddLastRunAtToTests < ActiveRecord::Migration

  class TestResult < ActiveRecord::Base
  end

  class TestInfo < ActiveRecord::Base
    has_many :test_results
  end

  def up

    rename_column :test_results, :updated_at, :run_at

    add_column :test_infos, :last_run_at, :datetime
    TestInfo.reset_column_information

    say_with_time "setting last run date for #{TestInfo.count} tests" do
      TestInfo.select(:id).all.each do |test|
        test.update_attribute :last_run_at, test.test_results.select('id, run_at').order('run_at DESC').limit(1).first.run_at
      end
    end

    change_column :test_infos, :last_run_at, :datetime, :null => false
  end

  def down
    remove_column :test_infos, :last_run_at
    rename_column :test_results, :run_at, :updated_at
  end
end

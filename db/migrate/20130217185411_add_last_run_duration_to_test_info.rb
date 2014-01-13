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
class AddLastRunDurationToTestInfo < ActiveRecord::Migration

  class TestInfo < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base; end

  def up

    add_column :test_infos, :last_run_duration, :integer
    TestInfo.reset_column_information

    say_with_time "setting last run duration for #{TestInfo.count} tests" do
      TestInfo.select('id').all.each do |test|
        last_result = TestResult.where(test_info_id: test.id).order('run_at DESC').limit(1).first
        test.update_attribute :last_run_duration, last_result.duration if last_result.present?
      end
    end

    change_column :test_infos, :last_run_duration, :integer, :null => false
  end

  def down
    remove_column :test_infos, :last_run_duration
  end
end

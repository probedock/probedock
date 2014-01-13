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
class AddActiveToTestResult < ActiveRecord::Migration

  class TestResult < ActiveRecord::Base
  end

  class TestInfo < ActiveRecord::Base
  end

  def up

    add_column :test_results, :active, :boolean, :null => false, :default => true

    say_with_time "copying active status from tests to results" do
      TestResult.where(test_info_id: TestInfo.where(active: false).pluck(:id)).update_all active: false
    end
  end

  def down
    remove_column :test_results, :active
  end
end

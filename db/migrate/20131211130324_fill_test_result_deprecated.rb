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
class FillTestResultDeprecated < ActiveRecord::Migration
  class TestInfo < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base
    belongs_to :test_info
  end

  def up

    deprecated_tests = TestInfo.select('id, deprecated_at').where('deprecated_at IS NOT NULL').all
    say_with_time "deprecating results for #{deprecated_tests.length} tests" do

      deprecated_tests.inject(0) do |memo,test|
        memo + TestResult.where('test_results.test_info_id = ? AND test_results.run_at >= ?', test.id, test.deprecated_at).update_all(deprecated: true)
      end
    end
  end

  def down
    rel = TestResult.where deprecated: true
    say_with_time "undeprecating #{rel.count} results" do
      rel.update_all deprecated: false
    end
  end
end

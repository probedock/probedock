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

class TestsData

  def self.compute
    JsonCache.new(:tests_status){ compute_data.deep_stringify_keys! }
  end

  private

  def self.compute_data
    settings = Settings::App.get
    {
      tests: TestInfo.standard.count,
      results: TestResult.count,
      runs: TestRun.count,
      failing_tests: TestInfo.failing.count,
      inactive_tests: TestInfo.inactive.count,
      outdated_tests: TestInfo.outdated(settings).count,
      outdated_days: settings.test_outdated_days,
      deprecated_tests: TestInfo.deprecated.count
    }
  end
end

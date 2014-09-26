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
FactoryGirl.define do

  factory :test_result, aliases: [ :result ] do
    passed true
    runner
    test_info
    run_at{ Time.now }
    category{ test_info.category }
    project_version{ create :project_version, project: test_info.project }
    duration 750
    test_run{ create :test_run, runner: runner }
  end
end

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

FactoryGirl.define do

  factory :test_info, aliases: [ :test ] do

    ignore do
      runner nil
      test_run nil
      run_at nil
      run_duration nil
      project_version nil
    end

    key
    author{ key.user }
    project{ key.project }
    name 'A test'
    passing true
    active true
    last_run_at{ Time.now }
    last_run_duration{ 100 }

    after :create do |test,evaluator|

      runner = evaluator.runner || evaluator.test_run.try(:runner) || test.author
      run_at = evaluator.run_at || evaluator.test_run.try(:ended_at) || test.last_run_at
      duration = evaluator.run_duration || evaluator.test_run.try(:duration) || test.last_run_duration

      run = evaluator.test_run || create(:run, runner: runner, ended_at: run_at, duration: duration)

      result_data = { test_info: test, passed: test.passing, active: test.active, category: test.category }
      result_data.merge! runner: runner, test_run: run, run_at: run_at, duration: duration, new_test: true
      result_data.merge! project_version: evaluator.project_version if evaluator.project_version
      result = create :test_result, result_data

      test.last_run_at = result.run_at
      test.last_run_duration = result.duration
      test.effective_result_id = result.id
      test.save!
    end
  end
end

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
class AddCountersToTestRun < ActiveRecord::Migration

  class TestRun < ActiveRecord::Base
    has_many :test_results
  end

  class TestResult < ActiveRecord::Base
  end

  def up

    change_table :test_runs do |t|
      t.integer :results_count, null: false
      t.integer :passed_results_count, null: false
      t.integer :inactive_results_count, null: false
      t.integer :inactive_passed_results_count, null: false
    end

    base = TestRun.select('test_runs.id, count(test_results.id) AS results_count').joins(:test_results).group('test_runs.id')

    counts = {}
    n = TestRun.count

    say_with_time "calculating counters for #{n} test runs" do
      count_results :results_count, base, counts
      count_results :passed_results_count, base.where('test_results.passed = ?', true), counts
      count_results :inactive_results_count, base.where('test_results.active = ?', false), counts
      count_results :inactive_passed_results_count, base.where('test_results.active = ? AND test_results.passed = ?', false, true), counts
    end

    run_ids = counts.keys
    (n / 1000.0).ceil.times do |i|
      last = (i + 1) * 1000
      last = n if last > n
      say_with_time "setting counters of test runs #{(i* 1000) + 1}-#{last}" do
        run_ids[i * 1000, 1000].each do |run_id|
          TestRun.where(id: run_id).update_all counts[run_id]
        end
      end
    end

    change_column :test_runs, :results_count, :integer, null: false
    change_column :test_runs, :passed_results_count, :integer, null: false
    change_column :test_runs, :inactive_results_count, :integer, null: false
    change_column :test_runs, :inactive_passed_results_count, :integer, null: false
  end

  def down
    remove_column :test_runs, :results_count
    remove_column :test_runs, :passed_results_count
    remove_column :test_runs, :inactive_results_count
    remove_column :test_runs, :inactive_passed_results_count
  end

  private

  def count_results type, query, counts
    query.all.each{ |run| (counts[run.id] ||= {})[type] = run.results_count }
  end
end

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
class DuplicateResultData < ActiveRecord::Migration
  class Category < ActiveRecord::Base; end
  class TestInfo < ActiveRecord::Base; end
  class TestRun < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base
    belongs_to :test_run
  end

  def up

    TestResult.reset_column_information

    batch = 0
    batch_size = 50
    total_results = TestResult.count
    processed_results = 0

    new_test_updates = []
    previous_passed_updates = { true => [], false => [] }
    previous_active_updates = { true => [], false => [] }

    TestInfo.select('id').find_in_batches batch_size: batch_size do |tests|

      percent_remaining = 100
      percent_remaining -= 100 * processed_results / total_results.to_f if processed_results >= 1
      percent_remaining = (percent_remaining * 100).round / 100.to_f

      batch += 1
      start = (batch - 1) * batch_size

      test_cache = tests.inject({}){ |memo,t| memo[t.id] = {}; memo }

      say_with_time "fetching result data for tests #{start + 1}-#{start + tests.length} (#{total_results - processed_results} results / #{percent_remaining}% remaining)" do

        current_results = 0
        results = TestResult.where(test_info_id: tests.collect{ |t| t.id }).order('run_at ASC').select('id,test_info_id,passed,active').all

        results.each do |result|
          if previous_result = test_cache[result.test_info_id][:previous_result]
            previous_passed_updates[previous_result.passed] << result.id if result.passed != previous_result.passed
            previous_active_updates[previous_result.active] << result.id if result.active != previous_result.active
          else
            new_test_updates << result.id
          end
          test_cache[result.test_info_id][:previous_result] = result
        end

        processed_results += results.length
        current_results += results.length
      end
    end

    say_with_time "updating #{total_results} results" do

      say_with_time "setting new_test for first results" do
        TestResult.where('id IN (?)', new_test_updates).update_all new_test: true if new_test_updates.any?
      end

      Category.all.each do |category|
        tests = TestInfo.where category_id: category.id
        say_with_time "setting category '#{category.name}' for the results of #{tests.count} tests" do
          TestResult.where(test_info_id: tests.select('id').all.collect{ |t| t.id }).update_all category_id: category.id, previous_category_id: category.id
        end
      end

      say_with_time "fixing previous category for new tests" do
        TestResult.where(new_test: true).update_all previous_category_id: nil
      end

      say_with_time "setting previous_passed for fixed/broken results" do
        previous_passed_updates.each_pair do |pp,ids|
          TestResult.where(id: ids).update_all previous_passed: pp if ids.any?
        end
        previous_passed_updates.values.inject(0){ |memo,ids| memo + ids.length }
      end

      say_with_time "setting previous_active for activated/deactivated results" do
        previous_active_updates.each_pair do |pa,ids|
          TestResult.where(id: ids).update_all previous_active: pa if ids.any?
        end
        previous_active_updates.values.inject(0){ |memo,ids| memo + ids.length }
      end

      nil
    end
  end

  def down
  end
end

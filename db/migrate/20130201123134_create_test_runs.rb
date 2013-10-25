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
class CreateTestRuns < ActiveRecord::Migration

  class TestKey < ActiveRecord::Base; end

  class TestInfo < ActiveRecord::Base
    belongs_to :test_key, foreign_key: :key_id
  end

  class TestResult < ActiveRecord::Base; end

  class TestRun < ActiveRecord::Base; end

  def up

    create_table :test_runs do |t|

      t.string :uid
      t.string :group
      t.datetime :ended_at, null: false
      t.integer :duration, null: false
      t.references :runner, null: false

      t.timestamps null: false
    end

    add_index :test_runs, :uid, unique: true
    add_index :test_runs, :group
    add_foreign_key :test_runs, :users, column: 'runner_id'

    add_column :test_results, :test_run_id, :integer
    add_foreign_key :test_results, :test_runs

    TestResult.reset_column_information

    bad_data = {
      '6537130b985c' => [ '17c3fefe90ab' ],
      'df8fb17de324' => [ 'd3250ab19130' ],
      'e566ec76a1d9' => [ '4c87c6911cbb', '780bcc9d157a' ],
      'df8fb17de324' => [ 'da68a367a48a' ]
    }

    bad_data = bad_data.inject({}) do |memo,(k,v)|
      memo[test_info_id_by_key(k)] = v.collect{ |key| test_info_id_by_key(key) }
      memo
    end

    remaining = TestResult.count
    runs = 0

    say "creating test runs for #{remaining} results"

    batch_size = 2000
    estimated_test_run_duration = 10.minutes
    offset = 0

    previous = []
    last_run = nil
    last_results = []
    bad_result_count = 0

    begin
      say_with_time "processing batch of #{batch_size} results, #{runs} runs created, #{remaining} results remaining" do

        results = previous + TestResult.select('id, duration, runner_id, test_info_id, created_at').order('created_at ASC').offset(offset).limit(batch_size).all
        previous.clear

        fixed_results = 0

        while results.any?

          first = results.first
          matching = results.select{ |r| r.runner_id == first.runner_id and r.created_at - first.created_at < estimated_test_run_duration }.uniq{ |r| r.test_info_id }

          if matching.length == 1 and bad_data.key?(matching.first.test_info_id)

            bad_result = matching.first
            bad_result_count += 1
            fixed_results += 1

            bad_result.test_info_id = bad_data[bad_result.test_info_id].sample

            if last_run
              within_last_run = (last_run.ended_at - bad_result.created_at).abs < estimated_test_run_duration
              if within_last_run and !last_results.any?{ |r| r.test_info_id == bad_result.test_info_id }
                bad_result.test_run_id = last_run.id
                last_results << bad_result
                results -= matching
                remaining -= matching.length
              end
            end

            bad_result.save!
            
            next
          end

          results -= matching
          remaining -= matching.length

          run = TestRun.new
          run.runner_id = first.runner_id
          run.ended_at = matching.last.created_at
          run.duration = matching.select{ |r| r.duration.present? }.inject(0){ |memo,r| memo + r.duration }
          run.save!

          last_run = run
          last_results = matching.dup

          runs += 1

          TestResult.where(id: matching.collect(&:id)).update_all test_run_id: run.id

          newer_result = results.find{ |r| !matching.include?(r) and r.created_at > matching.last.created_at }
          if newer_result.blank?
            previous = results
            break
          end
        end

        say "fixed #{fixed_results} results with duplicate keys" if fixed_results >= 1

        offset += batch_size
      end
    end while remaining >= 1

    change_column :test_results, :test_run_id, :integer, null: false
  end

  def down
    remove_foreign_key :test_results, :test_run
    remove_column :test_results, :test_run_id
    remove_index :test_runs, :uid
    remove_index :test_runs, :group
    remove_foreign_key :test_runs, :runner
    drop_table :test_runs
  end

  private

  def test_info_id_by_key key
    TestInfo.select('test_infos.id').joins(:test_key).where('test_keys.key = ?', key).first.id
  end
end

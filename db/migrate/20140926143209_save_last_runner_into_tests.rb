class SaveLastRunnerIntoTests < ActiveRecord::Migration
  class TestInfo < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base; end

  def up

    add_column :test_infos, :last_runner_id, :integer
    TestInfo.reset_column_information

    TestInfo.find_in_batches.with_index do |batch,i|
      say_with_time "setting last runner for tests #{i * 1000 + 1}-#{(i + 1) * 1000}" do
        batch.each do |test_info|
          TestInfo.select('id').where(id: test_info.id).update_all last_runner_id: TestResult.select(:runner_id).where(test_info_id: test_info.id).order('run_at desc').limit(1).first.runner_id
        end
      end
    end

    add_foreign_key :test_infos, :users, column: :last_runner_id
  end

  def down
    remove_column :test_infos, :last_runner_id
  end
end

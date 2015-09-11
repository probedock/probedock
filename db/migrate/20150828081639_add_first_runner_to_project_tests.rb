class AddFirstRunnerToProjectTests < ActiveRecord::Migration
  class TestResult < ActiveRecord::Base; end
  class ProjectTest < ActiveRecord::Base; end

  def up
    add_column :project_tests, :first_runner_id, :integer
    add_foreign_key :project_tests, :users, column: :first_runner_id

    i = 0
    count = ProjectTest.count

    ProjectTest.select(:id).find_in_batches batch_size: 250 do |tests|
      say_with_time "set first runner of tests #{i + 1}-#{i + tests.length} (out of #{count})" do
        tests.each do |test|
          first_result = TestResult.where(test_id: test.id).order('run_at ASC').limit(1).first
          ProjectTest.where(id: test.id).update_all first_runner_id: first_result.runner_id if first_result.present?
        end

        i += tests.length
      end
    end
  end

  def down
    remove_column :project_tests, :first_runner_id
  end
end

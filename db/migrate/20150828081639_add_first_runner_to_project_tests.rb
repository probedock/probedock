class AddFirstRunnerToProjectTests < ActiveRecord::Migration
  class TestResult < ActiveRecord::Base; end
  class ProjectTest < ActiveRecord::Base; end

  def up
    add_column :project_tests, :first_runner_id, :integer
    add_foreign_key :project_tests, :users, column: :first_runner_id

    count = ProjectTest.count

    say_with_time "set first runner of #{count} tests" do
      ProjectTest.find_each do |test|
        first_result = TestResult.where(test_id: test.id).order('run_at ASC').limit(1).first
        test.update_attribute :first_runner_id, first_result.runner_id if first_result.present?
      end
    end
  end

  def down
    remove_column :project_tests, :first_runner_id
  end
end

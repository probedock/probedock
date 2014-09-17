class DeleteTestRunResultsWithForeignKey < ActiveRecord::Migration

  def up
    remove_foreign_key :test_results, :test_runs
    add_foreign_key :test_results, :test_runs, dependent: :delete
  end

  def down
    remove_foreign_key :test_results, :test_runs
    add_foreign_key :test_results, :test_runs
  end
end

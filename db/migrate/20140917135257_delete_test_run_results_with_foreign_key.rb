class DeleteTestRunResultsWithForeignKey < ActiveRecord::Migration

  def up
    change_table :test_results do |t|
      t.remove_foreign_key :test_runs
      t.foreign_key :test_runs, dependent: :delete
    end
  end

  def down
    change_table :test_results do |t|
      t.remove_foreign_key :test_runs
      t.foreign_key :test_runs
    end
  end
end

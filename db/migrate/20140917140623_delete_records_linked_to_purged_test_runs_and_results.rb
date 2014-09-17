class DeleteRecordsLinkedToPurgedTestRunsAndResults < ActiveRecord::Migration

  def up
    remove_foreign_key :test_infos, :effective_result
    add_foreign_key :test_infos, :test_results, column: :effective_result_id, dependent: :nullify
    remove_foreign_key :test_deprecations, :test_results
    change_column :test_deprecations, :test_result_id, :integer, null: true
    add_foreign_key :test_deprecations, :test_results, dependent: :nullify
    remove_foreign_key :users, :last_run
    add_foreign_key :users, :test_runs, column: :last_run_id, dependent: :nullify
    remove_foreign_key :test_payloads, :test_runs
    add_foreign_key :test_payloads, :test_runs, dependent: :delete
    remove_foreign_key :test_keys_payloads, :test_payloads
    add_foreign_key :test_keys_payloads, :test_payloads, dependent: :delete
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

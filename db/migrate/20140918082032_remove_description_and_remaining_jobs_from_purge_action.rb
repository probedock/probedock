class RemoveDescriptionAndRemainingJobsFromPurgeAction < ActiveRecord::Migration
  def up
    remove_column :purge_actions, :description
    remove_column :purge_actions, :remaining_jobs
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

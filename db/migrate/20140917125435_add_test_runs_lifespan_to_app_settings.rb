class AddTestRunsLifespanToAppSettings < ActiveRecord::Migration

  def up
    add_column :app_settings, :test_runs_lifespan, :integer
    Settings::App.update_all test_runs_lifespan: 60
    change_column :app_settings, :test_runs_lifespan, :integer, null: false
  end

  def down
    remove_column :app_settings, :test_runs_lifespan
  end
end

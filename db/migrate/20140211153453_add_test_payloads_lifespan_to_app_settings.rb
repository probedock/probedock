class AddTestPayloadsLifespanToAppSettings < ActiveRecord::Migration

  def up
    add_column :app_settings, :test_payloads_lifespan, :integer
    Settings::App.update_all test_payloads_lifespan: 7
    change_column :app_settings, :test_payloads_lifespan, :integer, null: false
  end

  def down
    remove_column :app_settings, :test_payloads_lifespan
  end
end

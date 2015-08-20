class UpdateAppSettings < ActiveRecord::Migration
  class Settings::App < ActiveRecord::Base
    self.table_name = 'app_settings'
  end

  def up
    add_column :app_settings, :user_registration_enabled, :boolean, null: false, default: false
    remove_column :app_settings, :ticketing_system_url
    remove_column :app_settings, :reports_cache_size
    remove_column :app_settings, :tag_cloud_size
    remove_column :app_settings, :test_outdated_days
    remove_column :app_settings, :test_payloads_lifespan
    remove_column :app_settings, :test_runs_lifespan
    Settings::App.update_all user_registration_enabled: true
  end

  def down
    Settings::App.first.destroy

    add_column :app_settings, :reports_cache_size, :integer, null: false
    add_column :app_settings, :tag_cloud_size, :integer, null: false
    add_column :app_settings, :test_outdated_days, :integer, null: false
    add_column :app_settings, :test_payloads_lifespan, :integer, null: false
    add_column :app_settings, :test_runs_lifespan, :integer, null: false
    add_column :app_settings, :ticketing_system_url, :string, limit: 255
    remove_column :app_settings, :user_registration_enabled

    Settings::App.reset_column_information

    Settings::App.new({
      reports_cache_size: 50,
      tag_cloud_size: 50,
      test_outdated_days: 30,
      test_payloads_lifespan: 7,
      test_runs_lifespan: 60
    }).save!
  end
end

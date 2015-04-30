# Copyright (c) 2015 42 inside
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
class V3 < ActiveRecord::Migration

  def up
    remove_foreign_key :test_infos, :deprecation
    remove_foreign_key :test_payloads, :test_run
    remove_foreign_key :test_results, :test_run
    remove_foreign_key :users, :last_run
    remove_foreign_key :users, column: :settings_id
    remove_foreign_key :test_results, :test_infos

    drop_table :app_settings
    drop_table :user_settings
    drop_table :api_keys
    drop_table :links
    drop_table :link_templates
    drop_table :purge_actions
    drop_table :test_counters
    drop_table :test_deprecations
    drop_table :tags_test_infos
    drop_table :test_infos_tickets
    drop_table :test_runs
    drop_table :test_values
    drop_table :test_infos
    drop_table :test_results
    drop_table :test_keys_payloads
    drop_table :test_payloads
    drop_table :test_keys
    drop_table :project_versions
    drop_table :projects
    drop_table :categories
    drop_table :tags
    drop_table :tickets
    drop_table :users

    create_table :app_settings do |t|
      t.string :ticketing_system_url, limit: 255
      t.integer :reports_cache_size, null: false
      t.integer :tag_cloud_size, null: false
      t.integer :test_outdated_days, null: false
      t.integer :test_payloads_lifespan, null: false
      t.integer :test_runs_lifespan, null: false
      t.datetime :updated_at, null: false
    end

    create_table :organizations do |t|
      t.string :api_id, null: false, limit: 5
      t.string :name, null: false, limit: 50
      t.string :display_name, limit: 50
      t.string :normalized_name, null: false, limit: 50
      t.boolean :public_access, null: false, default: false
      t.integer :memberships_count, null: false, default: 0
      t.integer :projects_count, null: false, default: 0
      t.timestamps null: false
      t.index :api_id, unique: true
      t.index :name, unique: true
      t.index :normalized_name, unique: true
    end

    create_table :users do |t|
      t.string :api_id, null: false, limit: 5
      t.string :name, null: false, limit: 25
      t.boolean :active, null: false, default: true
      t.string :password_digest, null: false, limit: 255
      t.integer :roles_mask, null: false, default: 0
      t.integer :primary_email_id
      t.timestamps null: false
      t.index :api_id, unique: true
      t.index :name, unique: true
      t.index :primary_email_id, unique: true
    end

    create_table :emails do |t|
      t.string :address, null: false, limit: 255
      t.boolean :active, null: false, default: false
      t.integer :user_id
      t.index :address, unique: true
    end

    add_foreign_key :emails, :users, on_delete: :nullify

    add_foreign_key :users, :emails, column: :primary_email_id

    create_table :memberships do |t|
      t.string :api_id, null: false, limit: 12
      t.integer :user_id
      t.integer :organization_email_id, null: false
      t.integer :organization_id, null: false
      t.integer :roles_mask, null: false, default: 0
      t.string :otp, limit: 255
      t.datetime :expires_at
      t.datetime :accepted_at
      t.timestamps null: false
      t.index :api_id, unique: true
      t.index :otp, unique: true
      t.index [ :user_id, :organization_id ], unique: true
    end

    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :organizations
    add_foreign_key :memberships, :emails, column: :organization_email_id

    create_table :projects do |t|
      t.string :api_id, null: false, limit: 12
      t.string :name, null: false, limit: 50
      t.string :display_name, limit: 50
      t.string :normalized_name, null: false, limit: 50
      t.text :description
      t.integer :organization_id, null: false
      t.integer :tests_count, null: false, default: 0
      t.integer :deprecated_tests_count, null: false, default: 0
      t.timestamps null: false
      t.index :api_id, unique: true
    end

    add_foreign_key :projects, :organizations

    create_table :project_versions do |t|
      t.string :name, null: false, limit: 255
      t.integer :project_id, null: false
      t.datetime :created_at, null: false
      t.index [ :name, :project_id ], unique: true
    end

    add_foreign_key :project_versions, :projects

    create_table :test_keys do |t|
      t.string :key, null: false, limit: 12
      t.boolean :free, null: false, default: true
      t.boolean :tracked, null: false, default: true
      t.integer :project_id, null: false
      t.integer :user_id
      t.timestamps null: false
      t.index [ :key, :project_id ], unique: true
    end

    add_foreign_key :test_keys, :projects
    add_foreign_key :test_keys, :users

    create_table :project_tests do |t|
      t.string :name, null: false
      t.integer :key_id, null: false
      t.integer :project_id, null: false
      t.integer :results_count, null: false, default: 0
      t.timestamps null: false
      t.index [ :project_id, :key_id ], unique: true
    end

    add_foreign_key :project_tests, :test_keys, column: :key_id
    add_foreign_key :project_tests, :projects

    create_table :categories do |t|
      t.string :name, null: false, limit: 255
      t.integer :organization_id, null: false
      t.datetime :created_at, null: false
      t.index [ :name, :organization_id ], unique: true
    end

    add_foreign_key :categories, :organizations

    create_table :tags do |t|
      t.string :name, null: false, limit: 50
      t.integer :organization_id, null: false
      t.datetime :created_at, null: false
      t.index [ :name, :organization_id ], unique: true
    end

    add_foreign_key :tags, :organizations

    create_table :tickets do |t|
      t.string :name, null: false, limit: 255
      t.integer :organization_id, null: false
      t.datetime :created_at, null: false
      t.index [ :name, :organization_id ], unique: true
    end

    add_foreign_key :tickets, :organizations

    create_table :test_payloads do |t|
      t.string :api_id, null: false, limit: 36
      t.string :state, null: false, limit: 20
      t.json :contents, null: false
      t.integer :contents_bytesize, null: false
      t.integer :duration
      t.integer :results_count, null: false, default: 0
      t.integer :passed_results_count, null: false, default: 0
      t.integer :inactive_results_count, null: false, default: 0
      t.integer :inactive_passed_results_count, null: false, default: 0
      t.text :backtrace
      t.integer :runner_id, null: false
      t.integer :project_version_id
      t.datetime :received_at, null: false
      t.datetime :processing_at
      t.datetime :processed_at
      t.timestamps null: false
      t.index :api_id, unique: true
      t.index :state
    end

    add_foreign_key :test_payloads, :project_versions
    add_foreign_key :test_payloads, :users, column: :runner_id

    create_table :test_keys_payloads, id: false do |t|
      t.integer :test_key_id, null: false
      t.integer :test_payload_id, null: false
      t.index [ :test_key_id, :test_payload_id ], unique: true
    end

    add_foreign_key :test_keys_payloads, :test_keys
    add_foreign_key :test_keys_payloads, :test_payloads

    create_table :test_results do |t|
      t.string :name, null: false, limit: 255
      t.boolean :passed, null: false
      t.integer :duration, null: false
      t.text :message
      t.boolean :active, null: false
      t.boolean :new_test, null: false
      t.integer :payload_properties_set, null: false, default: 0
      t.json :custom_values
      t.integer :runner_id, null: false
      t.integer :test_id
      t.integer :project_version_id, null: false
      t.integer :test_payload_id, null: false
      t.integer :key_id
      t.integer :category_id
      t.datetime :run_at, null: false
      t.datetime :created_at, null: false
    end

    add_foreign_key :test_results, :categories
    add_foreign_key :test_results, :project_tests, column: :test_id
    add_foreign_key :test_results, :project_versions
    add_foreign_key :test_results, :test_keys, column: :key_id
    add_foreign_key :test_results, :test_payloads
    add_foreign_key :test_results, :users, column: :runner_id

    create_table :test_descriptions do |t|
      t.string :name, null: false
      t.integer :test_id, null: false
      t.integer :project_version_id, null: false
      t.integer :category_id
      t.boolean :passing, null: false
      t.boolean :active, null: false
      t.integer :last_duration, null: false
      t.timestamp :last_run_at, null: false
      t.integer :last_runner_id, null: false
      t.integer :last_result_id
      t.integer :results_count, null: false, default: 0
      t.json :custom_values
      t.timestamps null: false
      t.index [ :test_id, :project_version_id ], unique: true
    end

    add_foreign_key :test_descriptions, :project_tests, column: :test_id
    add_foreign_key :test_descriptions, :project_versions
    add_foreign_key :test_descriptions, :categories
    add_foreign_key :test_descriptions, :users, column: :last_runner_id
    add_foreign_key :test_descriptions, :test_results, column: :last_result_id

    create_table :tags_test_descriptions, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :tag_id, null: false
      t.index [ :test_description_id, :tag_id ], unique: true
    end

    add_foreign_key :tags_test_descriptions, :test_descriptions
    add_foreign_key :tags_test_descriptions, :tags

    create_table :test_descriptions_tickets, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :ticket_id, null: false
      t.index [ :test_description_id, :ticket_id ], unique: true, name: 'index_test_descriptions_on_description_and_ticket'
    end

    add_foreign_key :test_descriptions_tickets, :test_descriptions
    add_foreign_key :test_descriptions_tickets, :tickets

    create_table :test_contributors, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :email_id, null: false
      t.index [ :test_description_id, :email_id ], unique: true, name: 'index_test_contributors_on_description_and_email'
    end

    add_foreign_key :test_contributors, :test_descriptions
    add_foreign_key :test_contributors, :emails

    create_table :test_reports do |t|
      t.string :api_id, null: false, limit: 5
      t.integer :organization_id, null: false
      t.integer :runner_id, null: false
      t.timestamps null: false
      t.index :api_id, unique: true
    end

    add_foreign_key :test_reports, :organizations
    add_foreign_key :test_reports, :users, column: :runner_id

    create_table :test_payloads_reports, id: false do |t|
      t.integer :test_payload_id, null: false
      t.integer :test_report_id, null: false
      t.index [ :test_payload_id, :test_report_id ], unique: true, name: 'index_test_payloads_reports_on_payload_and_report_id'
    end

    add_foreign_key :test_payloads_reports, :test_payloads
    add_foreign_key :test_payloads_reports, :test_reports

    create_table :test_result_contributors, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :email_id, null: false
      t.index [ :test_result_id, :email_id ], unique: true, name: 'index_test_contributors_on_result_and_email'
    end

    add_foreign_key :test_result_contributors, :test_results
    add_foreign_key :test_result_contributors, :emails

    create_table :tags_test_results, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :tag_id, null: false
      t.index [ :test_result_id, :tag_id ], unique: true
    end

    add_foreign_key :tags_test_results, :test_results
    add_foreign_key :tags_test_results, :tags

    create_table :test_results_tickets, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :ticket_id, null: false
      t.index [ :test_result_id, :ticket_id ], unique: true
    end

    add_foreign_key :test_results_tickets, :test_results
    add_foreign_key :test_results_tickets, :tickets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

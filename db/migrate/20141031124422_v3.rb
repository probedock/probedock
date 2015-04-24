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
    remove_foreign_key :test_results, :test_infos
    drop_table :test_infos

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

    create_table :emails do |t|
      t.string :address, null: false, limit: 255
      t.index :address, unique: true
    end

    create_table :emails_users, id: false do |t|
      t.integer :email_id, null: false
      t.integer :user_id, null: false
      t.index :email_id, unique: true
    end

    add_foreign_key :emails_users, :emails
    add_foreign_key :emails_users, :users

    remove_column :categories, :metric_key
    add_column :categories, :organization_id, :integer, null: false
    add_foreign_key :categories, :organizations

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
    end

    add_foreign_key :memberships, :users
    add_foreign_key :memberships, :organizations
    add_foreign_key :memberships, :emails, column: :organization_email_id

    remove_column :projects, :metric_key
    remove_column :projects, :url_token
    add_column :projects, :description, :text
    change_column :projects, :name, :string, limit: 50
    add_column :projects, :organization_id, :integer, null: false
    add_foreign_key :projects, :organizations

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

    add_column :tags, :organization_id, :integer, null: false
    add_foreign_key :tags, :organizations

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
      t.integer :test_description_id
      t.integer :email_id
      t.index [ :test_description_id, :email_id ], unique: true, name: 'index_test_contributors_on_description_and_email'
    end

    add_foreign_key :test_contributors, :test_descriptions
    add_foreign_key :test_contributors, :emails

    change_column :test_keys, :user_id, :integer, null: true
    add_column :test_keys, :tracked, :boolean, null: false, default: true

    remove_column :test_payloads, :test_run_id
    add_column :test_payloads, :api_id, :string, null: false, limit: 36
    rename_column :test_payloads, :user_id, :runner_id
    remove_column :test_payloads, :contents
    change_column :test_payloads, :state, :string, null: false, limit: 20
    add_column :test_payloads, :contents, :json, null: false
    add_column :test_payloads, :duration, :integer
    add_column :test_payloads, :run_ended_at, :datetime
    add_column :test_payloads, :results_count, :integer, null: false, default: 0
    add_column :test_payloads, :passed_results_count, :integer, null: false, default: 0
    add_column :test_payloads, :inactive_results_count, :integer, null: false, default: 0
    add_column :test_payloads, :inactive_passed_results_count, :integer, null: false, default: 0
    add_column :test_payloads, :project_version_id, :integer
    add_column :test_payloads, :backtrace, :text
    add_column :test_payloads, :processed_results_count, :integer, null: false, default: 0
    add_column :test_payloads, :results_processed_at, :datetime
    add_index :test_payloads, :api_id, unique: true
    add_foreign_key :test_payloads, :project_versions

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

    remove_index :test_results, [ :test_run_id, :test_info_id ]
    remove_column :test_results, :test_run_id
    remove_column :test_results, :previous_passed
    remove_column :test_results, :previous_active
    remove_column :test_results, :previous_category_id
    remove_column :test_results, :deprecated
    add_column :test_results, :test_payload_id, :integer, null: false
    add_column :test_results, :key_id, :integer
    add_column :test_results, :name, :string
    add_column :test_results, :payload_properties_set, :integer, null: false, default: 0
    add_column :test_results, :processed, :boolean, null: false, default: false
    add_column :test_results, :processed_at, :datetime
    rename_column :test_results, :test_info_id, :test_id
    change_column :test_results, :new_test, :boolean, null: true, default: nil
    change_column :test_results, :test_id, :integer, null: true
    add_foreign_key :test_results, :test_payloads
    add_foreign_key :test_results, :project_tests, column: :test_id
    add_foreign_key :test_results, :test_keys, column: :key_id

    create_table :test_result_contributors, id: false do |t|
      t.integer :test_result_id
      t.integer :email_id
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

    create_table :test_custom_values do |t|
      t.string :name, null: false, limit: 50
      t.text :contents, null: false
      t.index [ :name, :contents ], unique: true
    end

    create_table :test_custom_values_descriptions, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :test_custom_value_id, null: false
      t.index [ :test_description_id, :test_custom_value_id ], unique: true, name: 'index_test_custom_values_descriptions_on_desc_and_value_ids'
    end

    add_foreign_key :test_custom_values_descriptions, :test_descriptions
    add_foreign_key :test_custom_values_descriptions, :test_custom_values

    create_table :test_custom_values_results, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :test_custom_value_id, null: false
      t.index [ :test_result_id, :test_custom_value_id ], unique: true, name: 'index_test_custom_values_results_on_result_and_value_id'
    end

    add_foreign_key :test_custom_values_results, :test_results
    add_foreign_key :test_custom_values_results, :test_custom_values

    add_column :tickets, :organization_id, :integer, null: false
    add_foreign_key :tickets, :organizations

    remove_column :users, :remember_token
    remove_column :users, :remember_created_at
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :encrypted_password
    remove_column :users, :metric_key
    remove_column :users, :email
    remove_column :users, :last_run_id
    remove_column :users, :settings_id
    add_column :users, :primary_email_id, :integer
    add_column :users, :password_digest, :string, null: false
    add_column :users, :last_test_payload_id, :integer
    add_column :users, :api_id, :string, null: false, limit: 5
    change_column :users, :name, :string, null: false, limit: 25
    add_index :users, :api_id, unique: true
    add_index :users, :primary_email_id, unique: true
    add_foreign_key :users, :emails, column: :primary_email_id
    add_foreign_key :users, :test_payloads, column: :last_test_payload_id

    add_column :user_settings, :user_id, :integer
    add_index :user_settings, :user_id, unique: true
    add_foreign_key :user_settings, :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

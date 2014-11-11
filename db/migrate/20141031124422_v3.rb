# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
class V3 < ActiveRecord::Migration

  def up

    remove_foreign_key :test_infos, :deprecation

    drop_table :api_keys
    drop_table :links
    drop_table :test_counters
    drop_table :test_deprecations
    drop_table :tags_test_infos
    drop_table :test_infos_tickets
    drop_table :test_values
    remove_foreign_key :test_results, :test_infos
    drop_table :test_infos

    create_table :user_emails do |t|
      t.string :email, null: false
      t.index :email, unique: true
    end

    remove_column :categories, :metric_key

    remove_column :projects, :metric_key
    remove_column :projects, :url_token
    add_column :projects, :description, :text
    change_column :projects, :name, :string, limit: 100

    create_table :project_tests do |t|
      t.string :name, null: false
      t.integer :key_id, null: false
      t.integer :project_id, null: false
      t.integer :results_count, null: false, default: 0
      t.timestamps null: false
      t.index [ :project_id, :key_id ], unique: true
      t.foreign_key :test_keys, column: :key_id
      t.foreign_key :projects
    end

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
      t.foreign_key :project_tests, column: :test_id
      t.foreign_key :project_versions
      t.foreign_key :categories
      t.foreign_key :users, column: :last_runner_id
      t.foreign_key :test_results, column: :last_result_id
    end

    create_table :tags_test_descriptions, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :tag_id, null: false
      t.index [ :test_description_id, :tag_id ], unique: true
      t.foreign_key :test_descriptions
      t.foreign_key :tags
    end

    create_table :test_descriptions_tickets, id: false do |t|
      t.integer :test_description_id, null: false
      t.integer :ticket_id, null: false
      t.index [ :test_description_id, :ticket_id ], unique: true, name: 'index_test_descriptions_on_description_and_ticket'
      t.foreign_key :test_descriptions
      t.foreign_key :tickets
    end

    create_table :test_contributors, id: false do |t|
      t.integer :test_description_id
      t.integer :user_email_id
      t.index [ :test_description_id, :user_email_id ], unique: true, name: 'index_test_contributors_on_description_and_user_email'
      t.foreign_key :test_descriptions
      t.foreign_key :user_emails
    end

    change_column :test_keys, :user_id, :integer, null: true
    add_column :test_keys, :tracked, :boolean, null: false, default: true

    remove_column :test_payloads, :test_run_id
    add_column :test_payloads, :api_id, :string, null: false, limit: 36
    rename_column :test_payloads, :user_id, :runner_id
    remove_column :test_payloads, :contents
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
    add_index :test_payloads, :api_id, unique: true
    add_foreign_key :test_payloads, :project_versions

    create_table :test_reports do |t|
      t.string :api_id, null: false, limit: 12
      t.integer :runner_id, null: false
      t.timestamps null: false
      t.foreign_key :users, column: :runner_id
    end

    create_table :test_payloads_reports, id: false do |t|
      t.integer :test_payload_id, null: false
      t.integer :test_report_id, null: false
      t.index [ :test_payload_id, :test_report_id ], unique: true, name: 'index_test_payloads_reports_on_payload_and_report_id'
      t.foreign_key :test_payloads
      t.foreign_key :test_reports
    end

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
    rename_column :test_results, :test_info_id, :test_id
    change_column :test_results, :new_test, :boolean, null: true, default: nil
    change_column :test_results, :test_id, :integer, null: true
    add_index :test_results, [ :test_payload_id, :key_id ], unique: true
    add_foreign_key :test_results, :test_payloads
    add_foreign_key :test_results, :project_tests, column: :test_id
    add_foreign_key :test_results, :test_keys, column: :key_id

    create_table :test_result_contributors, id: false do |t|
      t.integer :test_result_id
      t.integer :user_email_id
      t.index [ :test_result_id, :user_email_id ], unique: true, name: 'index_test_contributors_on_result_and_user_email'
      t.foreign_key :test_results
      t.foreign_key :user_emails
    end

    create_table :tags_test_results, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :tag_id, null: false
      t.index [ :test_result_id, :tag_id ], unique: true
      t.foreign_key :test_results
      t.foreign_key :tags
    end

    create_table :test_results_tickets, id: false do |t|
      t.integer :test_result_id, null: false
      t.integer :ticket_id, null: false
      t.index [ :test_result_id, :ticket_id ], unique: true
      t.foreign_key :test_results
      t.foreign_key :tickets
    end

    create_table :test_values do |t|
      t.string :name, null: false, limit: 50
      t.text :contents, null: false
      t.integer :test_description_id, null: false
      t.index [ :name, :test_description_id ], unique: true
      t.foreign_key :test_descriptions
    end

    create_table :test_result_values do |t|
      t.string :name, null: false, limit: 50
      t.text :contents, null: false
      t.integer :test_result_id, null: false
      t.index [ :name, :test_result_id ], unique: true
      t.foreign_key :test_results
    end

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
    add_column :users, :email_id, :integer
    add_column :users, :password_digest, :string, null: false
    add_column :users, :last_test_payload_id, :integer
    add_column :users, :api_id, :string, null: false, limit: 12
    add_index :users, :email_id, unique: true
    add_foreign_key :users, :user_emails, column: :email_id
    add_foreign_key :users, :test_payloads, column: :last_test_payload_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

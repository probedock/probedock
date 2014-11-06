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
    drop_table :test_counters
    drop_table :test_deprecations

    create_table :user_emails do |t|
      t.string :email, null: false
      t.index :email, unique: true
    end

=begin
    create_table :test_contributors, id: false do |t|
      t.integer :contributor_id, null: false
      t.integer :test_info_id, null: false
      t.index [ :contributor_id, :test_info_id ], unique: true
      t.foreign_key :contributors
      t.foreign_key :test_infos
    end

    create_table :test_result_contributors, id: false do |t|
      t.integer :contributor_id, null: false
      t.integer :test_result_id, null: false
      t.index [ :contributor_id, :test_result_id ], unique: true
      t.foreign_key :contributors
      t.foreign_key :test_results
    end
=end

    remove_column :categories, :metric_key

    remove_column :projects, :metric_key
    remove_column :projects, :url_token
    add_column :projects, :description, :text
    change_column :projects, :name, :string, limit: 100

    remove_column :test_infos, :deprecation_id
    remove_column :test_infos, :author_id
    add_column :test_infos, :deprecated_at, :datetime
    rename_column :test_infos, :effective_result_id, :last_result_id

    change_column :test_keys, :user_id, :integer, null: true

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
    add_index :test_payloads, :api_id, unique: true
    add_foreign_key :test_payloads, :project_versions

    remove_index :test_results, [ :test_run_id, :test_info_id ]
    remove_column :test_results, :test_run_id
    remove_column :test_results, :previous_passed
    remove_column :test_results, :previous_active
    remove_column :test_results, :previous_category_id
    add_column :test_results, :test_payload_id, :integer, null: false
    add_foreign_key :test_results, :test_payloads

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
    add_foreign_key :users, :user_emails, column: :email_id
    add_foreign_key :users, :test_payloads, column: :last_test_payload_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

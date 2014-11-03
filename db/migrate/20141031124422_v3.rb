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

    drop_table :api_keys

    remove_column :projects, :metric_key
    remove_column :projects, :url_token
    add_column :projects, :description, :text
    change_column :projects, :name, :string, limit: 100

    remove_column :test_payloads, :test_run_id
    add_column :test_payloads, :api_id, :string, null: false, limit: 12
    add_column :test_payloads, :run_ended_at, :datetime, null: false
    rename_column :test_payloads, :user_id, :runner_id
    remove_column :test_payloads, :contents
    add_column :test_payloads, :contents, :json, null: false
    add_index :test_payloads, :api_id, unique: true

    remove_column :users, :remember_token
    remove_column :users, :remember_created_at
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :encrypted_password
    remove_column :users, :metric_key
    add_column :users, :password_digest, :string, null: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

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

class CreateApiKeys < ActiveRecord::Migration
  class ApiKey < ActiveRecord::Base; end

  def up

    remove_column :users, :authentication_token

    create_table :api_keys do |t|
      t.string :identifier, null: false, limit: 20
      t.string :shared_secret, null: false, limit: 50
      t.boolean :active, null: false, default: true
      t.references :user, null: false
      t.integer :usage_count, null: false, default: 0
      t.datetime :last_used_at
      t.timestamps null: false
    end

    add_foreign_key :api_keys, :users
    add_index :api_keys, :identifier, unique: true

    users, keys = User.all, []

    say_with_time "creating api keys for #{users.length} users" do
      users.each do |u|

        next while keys.include?(id = SecureRandom.hex(10))
        keys << id

        ApiKey.new.tap do |k|
          k.identifier = id
          k.shared_secret = SecureRandom.hex(25)
          k.user_id = u.id
        end.save!
      end
    end
  end

  def down
    remove_foreign_key :api_keys, :user
    drop_table :api_keys
    add_column :users, :authentication_token, :string
    User.all.each{ |u| u.ensure_authentication_token! } if User.new.respond_to?(:ensure_authentication_token!)
  end
end

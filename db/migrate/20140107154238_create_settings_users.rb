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
class CreateSettingsUsers < ActiveRecord::Migration
  module Settings; end
  class Project < ActiveRecord::Base; end
  class User < ActiveRecord::Base
    belongs_to :settings, class_name: 'Settings::User'
  end
  class Settings::User < ActiveRecord::Base
    self.table_name = 'user_settings'
    belongs_to :user
    belongs_to :default_test_key_project, class_name: 'Project'
  end

  def up

    create_table :user_settings do |t|
      t.integer :default_test_key_project_id
      t.datetime :updated_at, null: false
      t.foreign_key :projects, column: :default_test_key_project_id
    end

    change_table :users do |t|
      t.integer :settings_id
    end

    Settings::User.reset_column_information

    users = User.select(:id).to_a
    say_with_time "creating settings for #{users.length} users" do
      users.each do |user|
        settings = Settings::User.new.tap(&:save!)
        user.update_attribute :settings_id, settings.id
      end
    end

    change_column :users, :settings_id, :integer, null: false
    add_index :users, :settings_id, unique: true
    add_foreign_key :users, :user_settings, column: :settings_id
  end

  def down
    remove_foreign_key :users, name: 'users_settings_id_fk'
    remove_column :users, :settings_id
    drop_table :user_settings
  end
end

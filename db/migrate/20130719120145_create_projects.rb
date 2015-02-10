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
class CreateProjects < ActiveRecord::Migration
  class Project < ActiveRecord::Base; end
  class TestInfo < ActiveRecord::Base; end

  def up

    create_table :projects do |t|

      t.string :name, null: false
      t.string :url_token, null: false, limit: 25
      t.string :api_id, null: false, limit: 12
      t.integer :active_tests_count, null: false, default: 0
      t.integer :deprecated_tests_count, null: false, default: 0

      t.timestamps null: false
    end

    add_index :projects, :api_id, unique: true

    add_column :test_infos, :project_id, :integer
    add_column :test_keys, :project_id, :integer

    remove_foreign_key :test_infos, :key
    remove_index :test_infos, :key_id

    api_ids = []

    project_names = TestInfo.pluck('distinct project').sort

    say_with_time "creating #{project_names.length} projects" do
      project_names.each do |name|
        say_with_time "creating project #{name}" do

          next while api_ids.include?(api_id = SecureRandom.hex(6))

          project = Project.new.tap do |p|

            p.name = name
            p.url_token = name.gsub(/ +/, '').underscore[0, 25]
            p.api_id = api_id

            tests = TestInfo.where project: name
            p.active_tests_count = tests.where(deprecated: false).count
            p.deprecated_tests_count = tests.where(deprecated: true).count

            first_test = tests.order('created_at asc').limit(1).first
            p.created_at = first_test.created_at if first_test
          end

          project.save!

          TestInfo.where(project: name).update_all project_id: project.id
          TestKey.joins(:test_info).update_all 'test_keys.project_id = test_infos.project_id'
        end
      end
    end

    biggest_project = Project.order('active_tests_count DESC').limit(1).first
    free_keys = TestKey.where('project_id IS NULL')
    say_with_time "assigning #{free_keys.length} free keys to project with the most tests" do
      free_keys.update_all project_id: biggest_project.id
    end

    change_column :test_infos, :project_id, :integer, null: false
    add_foreign_key :test_infos, :projects

    change_column :test_keys, :project_id, :integer, null: false
    add_foreign_key :test_keys, :projects
    remove_index :test_keys, :key
    add_index :test_keys, [ :key, :project_id ], unique: true

    remove_index :test_infos, :project
    remove_column :test_infos, :project
    add_index :test_infos, [ :key_id, :project_id ], unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

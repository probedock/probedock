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
class CreateProjectVersions < ActiveRecord::Migration
  class Project < ActiveRecord::Base; end
  class TestInfo < ActiveRecord::Base; end
  class TestRun < ActiveRecord::Base; end
  class TestResult < ActiveRecord::Base; end
  class ProjectVersion < ActiveRecord::Base
    belongs_to :project
  end

  def up

    create_table :project_versions do |t|
      t.string :name, null: false
      t.integer :project_id, null: false
      t.datetime :created_at, null: false
    end

    add_index :project_versions, [ :project_id, :name ], unique: true
    add_foreign_key :project_versions, :projects

    projects = say_with_time "fetching project data" do
      Project.all
    end

    tests_by_project = say_with_time "fetching test data" do
      projects.inject({}){ |memo,project| memo[project] = TestInfo.select('id, project_id').where(project_id: project.id).all; memo }
    end

    versions = []

    tests_by_project.each_pair do |project,tests|

      say_with_time "creating versions for project #{project.name}" do

        results = TestResult.where test_info_id: tests.collect{ |t| t.id }
        version_names = results.uniq.pluck(:version)
        say "versions are #{version_names.sort.join ', '}", true

        version_names.each do |name|
          created_at = results.select('run_at').where(version: name).order('run_at ASC').limit(1).first.run_at
          versions << ProjectVersion.new.tap{ |v| v.name = name; v.project = project; v.created_at = created_at; v.save! }
        end

        version_names.length
      end
    end

    versions.each do |version|

      results = TestResult.where test_info_id: tests_by_project[version.project], version: version.name
    
      say_with_time "updating #{version.project.name} results with version #{version.name}" do
        results.update_all project_version_id: version.id
      end
    end
  end

  def down

    ProjectVersion.includes(:project).all.each do |version|
      say_with_time "updating #{version.project.name} results with version #{version.name}" do
        TestResult.where(project_version_id: version).update_all version: version.name
      end
    end

    drop_table :project_versions
  end
end

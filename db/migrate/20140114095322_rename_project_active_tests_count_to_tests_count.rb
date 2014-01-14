class RenameProjectActiveTestsCountToTestsCount < ActiveRecord::Migration
  class Project < ActiveRecord::Base; end
  class TestInfo < ActiveRecord::Base; end

  def up

    rename_column :projects, :active_tests_count, :tests_count

    projects = Project.all.to_a
    say_with_time "updating test count and deprecated tests count for #{projects.length} projects" do
      projects.each do |p|
        test_rel = TestInfo.where project_id: p.id
        Project.where(id: p.id).update_all tests_count: test_rel.count, deprecated_tests_count: test_rel.where('deprecation_id IS NOT NULL').count
      end
    end
  end

  def down
    rename_column :projects, :tests_count, :active_tests_count
  end
end

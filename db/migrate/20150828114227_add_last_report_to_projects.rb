class AddLastReportToProjects < ActiveRecord::Migration
  class Project < ActiveRecord::Base
    has_many :project_versions
  end

  class ProjectVersion < ActiveRecord::Base
    belongs_to :project
  end

  class TestPayload < ActiveRecord::Base
    has_and_belongs_to_many :test_reports
  end

  class TestReport < ActiveRecord::Base
    has_and_belongs_to_many :test_payloads
  end

  def up
    add_column :projects, :last_report_id, :integer
    add_foreign_key :projects, :test_reports, column: :last_report_id

    count = Project.count
    say_with_time "setting last report for #{count} projects" do
      Project.select(:id).to_a.each do |project|
        versions = ProjectVersion.select(:id).where(project_id: project.id).to_a
        last_report = TestReport.select('test_reports.id').joins(:test_payloads).where('test_payloads.project_version_id IN (?)', versions.collect(&:id)).order('test_reports.ended_at DESC').limit(1).first
        Project.where(id: project.id).update_all last_report_id: last_report.id if last_report.present?
      end
    end
  end

  def down
    remove_column :projects, :last_report_id
  end
end

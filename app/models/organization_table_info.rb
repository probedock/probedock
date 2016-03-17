class OrganizationTableInfo
  attr_accessor :payloads_count, :projects_count, :tests_count, :results_count,
                :total_payloads_count, :total_projects_count, :total_tests_count, :total_results_count

  def initialize(org_stats)
    @payloads_count = org_stats[:test_payloads_count]
    @projects_count = org_stats[:projects_count]
    @tests_count = org_stats[:project_tests_count]
    @results_count = org_stats[:test_results_count]
    @total_payloads_count = org_stats[:total_test_payloads_count]
    @total_projects_count = org_stats[:total_projects_count]
    @total_tests_count = org_stats[:total_project_tests_count]
    @total_results_count = org_stats[:total_test_results_count]
  end

  def self.stats(organization)
    # We set a dummy existing state to make sure the query does not crash (related to gem simple_states)
    results_count = TestPayload.select('SUM(results_count) AS test_results_count, max(state) as state').joins(project_version: :project).where('projects.organization_id = ?', organization.id).take.test_results_count

    stats = {
      test_payloads_count: TestPayload.joins(project_version: :project).where('projects.organization_id = ?', organization.id).count,
      projects_count: Project.where('organization_id = ?', organization.id).count,
      project_tests_count: ProjectTest.joins(:project).where('projects.organization_id = ?', organization.id).count,
      test_results_count: results_count.nil? ? 0 : results_count
    }

    sql = 'SELECT' +
      ' table_name AS name,' +
      ' (SELECT reltuples::BIGINT FROM pg_class WHERE relname=table_name) AS count' +
    ' FROM (' +
      'SELECT' +
        ' table_name' +
      ' FROM' +
        ' information_schema.tables' +
      ' WHERE' +
        ' table_schema LIKE \'public\'' +
        ' AND table_name IN (\'test_payloads\', \'projects\', \'project_tests\', \'test_results\')' +
    ') AS all_tables'

    ActiveRecord::Base.connection.execute(sql).to_a.each { |table_stats| stats["total_#{table_stats['name']}_count".to_sym] = table_stats['count'].to_i }

    OrganizationTableInfo.new(stats)
  end
end
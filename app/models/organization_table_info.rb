class OrganizationTableInfo
  attr_accessor :organizations_counts, :total_counts

  def initialize(org_stats, total_counts)
    @organizations_counts = org_stats.kind_of?(Array) ? org_stats : [ org_stats ]
    @total_counts = total_counts
  end

  def self.stats(organization)
    # We set a dummy existing state to make sure the query does not crash (related to gem simple_states)
    results_count = TestPayload
      .select('SUM(results_count) AS test_results_count, max(state) as state')
      .joins(project_version: :project)
      .where('projects.organization_id = ?', organization.id)
      .take.test_results_count

    stats = {
      id: organization.api_id,
      name: organization.name,
      display_name: organization.display_name,
      test_payloads_count: TestPayload.joins(project_version: :project).where('projects.organization_id = ?', organization.id).count,
      projects_count: Project.where('organization_id = ?', organization.id).count,
      project_tests_count: ProjectTest.joins(:project).where('projects.organization_id = ?', organization.id).count,
      test_results_count: results_count.nil? ? 0 : results_count
    }

    OrganizationTableInfo.new(stats, total_counts)
  end

  def self.top_stats(quantity)
    # Retrieve the results count, payloads count and organization info for the top most consuming organizations
    org_payloads_and_results_count = Organization
      .select('
        organizations.id, organizations.api_id, organizations.name, organizations.display_name,
        SUM(test_payloads.results_count) AS test_results_count, COUNT(test_payloads.id) as test_payloads_count
      ')
      .joins('
        LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
        LEFT OUTER JOIN "project_versions" ON "project_versions"."project_id" = "projects"."id"
        LEFT OUTER JOIN"test_payloads" ON "test_payloads"."project_version_id" = "project_versions"."id"
      ')
      .group('organizations.id')
      .order('test_results_count DESC NULLS LAST')
      .limit(quantity)

    # Collect the ids
    org_ids = org_payloads_and_results_count.collect(&:id)

    # Retrieve the count data for projects
    organizations_projects_count = Organization
      .select('organizations.id as org_id, COUNT(projects.id) as projects_count')
      .joins('LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"')
      .where('organizations.id in (?)', org_ids)
      .group('organizations.id')
      .order('organizations.id').to_a

    # Retrieve the count data for tests
    organizations_project_tests_count = Organization
      .select('organizations.id as org_id, COUNT(project_tests.id) as project_tests_count')
      .joins('
        LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
        LEFT OUTER JOIN "project_tests" ON "project_tests"."project_id" = "projects"."id"
      ')
      .where('organizations.id in (?)', org_ids)
      .group('organizations.id')
      .order('organizations.id')

    # Create the array of each organization stats with organization details
    stats = []
    org_payloads_and_results_count.each do |payloads_and_results_count|
      # Retrieve the org_idx corresponding to the idx because we do not want to change the order of org
      org_idx = organizations_projects_count.index{ |organization_projects_count| organization_projects_count.org_id == payloads_and_results_count.id }

      # Create the stat hash
      stats << {
        id: payloads_and_results_count.api_id,
        name: payloads_and_results_count.name,
        display_name: payloads_and_results_count.display_name,
        test_payloads_count: payloads_and_results_count.test_payloads_count.nil? ? 0 : payloads_and_results_count.test_payloads_count,
        projects_count: organizations_projects_count[org_idx].projects_count.nil? ? 0 : organizations_projects_count[org_idx].projects_count,
        project_tests_count: organizations_project_tests_count[org_idx].project_tests_count.nil? ? 0 : organizations_project_tests_count[org_idx].project_tests_count,
        test_results_count: payloads_and_results_count.test_results_count.nil? ? 0 : payloads_and_results_count.test_results_count
      }
    end

    OrganizationTableInfo.new(stats, total_counts)
  end

  private

  def self.total_counts
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

    ActiveRecord::Base.connection.execute(sql).to_a.inject({}) do |memo, table_stats|
      memo["#{table_stats['name']}_count".to_sym] = table_stats['count'].to_i
      memo
    end
  end
end
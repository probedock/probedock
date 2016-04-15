class OrganizationTableInfo
  attr_accessor :organizations_counts, :total_counts

  def initialize(org_stats, total_counts)
    @organizations_counts = org_stats.kind_of?(Array) ? org_stats : [ org_stats ]
    @total_counts = total_counts
  end

  def self.top_stats(top: 5, organization: nil, trends_weeks: 5)
    # Retrieve the results count, payloads count and organization info for the top most consuming organizations
    orgs_counts_rel = Organization
      .select('
        organizations.id,
        organizations.api_id,
        organizations.name,
        organizations.display_name,
        organizations.projects_count,
        SUM(test_payloads.new_tests_count) AS tests_count,
        SUM(test_payloads.results_count) AS test_results_count, COUNT(test_payloads.id) AS test_payloads_count
      ')
      .joins('
        LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
        LEFT OUTER JOIN "project_versions" ON "project_versions"."project_id" = "projects"."id"
        LEFT OUTER JOIN "test_payloads" ON "test_payloads"."project_version_id" = "project_versions"."id"
      ')
      .group('organizations.id')
      .order('test_results_count DESC NULLS LAST, organizations.name ASC')

    # Retrieve the results trends for organizations
    orgs_trends_count_rel = Organization
      .select("
        organizations.id,
        SUM(test_payloads.results_count) AS test_results_count,
        date_trunc('week', test_payloads.processed_at) AS trend_date
      ")
      .joins('
        LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
        LEFT OUTER JOIN "project_versions" ON "project_versions"."project_id" = "projects"."id"
        LEFT OUTER JOIN "test_payloads" ON "test_payloads"."project_version_id" = "project_versions"."id"
      ')
      .group("organizations.id, date_trunc('week', test_payloads.processed_at)")
      .order('organizations.id, trend_date ASC')
      .where("date_trunc('week', test_payloads.processed_at) >= ?", trends_weeks.weeks.ago.at_beginning_of_week)

    # Add where clause to scope to specific organization
    if organization
      orgs_counts_rel = orgs_counts_rel.where('organizations.id = ?', organization.id)
      orgs_trends_count_rel = orgs_trends_count_rel.where('organizations.id = ?', organization.id)
    end

    # Add a limit to do the top n
    orgs_counts_rel = orgs_counts_rel.limit(top <= 0 ? 5 : top)

    # Execute the queries
    orgs_counts = orgs_counts_rel.to_a
    orgs_trends_count = orgs_trends_count_rel.to_a

    # Collect the ids
    org_ids = orgs_counts.collect(&:id)

    # Collect the results trend for each organization
    results_trend = {}
    org_ids.each do |org_id|
      # Get the DB records corresponding to the org.
      # In some cases, the number of results can be less than the number of weeks
      org_trends_count = orgs_trends_count.select{ |org_trends_count| org_trends_count.id == org_id }

      results_trend[org_id] = []

      (0..trends_weeks - 1).each do |week_idx|
        week_date = (week_idx + 1).weeks.ago.at_beginning_of_week

        # Try to find the data for the current week date
        week_trend = org_trends_count.find{ |org_trend| org_trend.trend_date == week_date }

        # Check if the DB returned data for the week date, otherwise consider as 0
        results_trend[org_id] << (week_trend.nil? ? 0 : week_trend.test_results_count)
      end
    end

    # Create the array of each organization stats with organization details
    stats = []
    orgs_counts.each do |org_counts|
      # Create the stat hash
      stats << {
        api_id: org_counts.api_id,
        name: org_counts.name,
        display_name: org_counts.display_name,
        test_payloads_count: org_counts.test_payloads_count,
        projects_count: org_counts.projects_count,
        project_tests_count: org_counts.tests_count.nil? ? 0 : org_counts.tests_count,
        test_results_count: org_counts.test_results_count.nil? ? 0 : org_counts.test_results_count,
        results_trend: results_trend[org_counts.id]
      }
    end

    OrganizationTableInfo.new(stats, total_counts(trends_weeks))
  end

  private

  def self.total_counts(weeks)
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

    res = ActiveRecord::Base.connection.execute(sql).to_a.inject({}) do |memo, table_stats|
      memo["#{table_stats['name']}_count".to_sym] = table_stats['count'].to_i
      memo
    end

    # Retrieve the results trends for all organizations
    results_trends_count = Organization
      .select("
        SUM(test_payloads.results_count) AS test_results_count,
        date_trunc('week', test_payloads.processed_at) AS trend_date
      ")
      .joins('
        LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
        LEFT OUTER JOIN "project_versions" ON "project_versions"."project_id" = "projects"."id"
        LEFT OUTER JOIN "test_payloads" ON "test_payloads"."project_version_id" = "project_versions"."id"
      ')
      .group("date_trunc('week', test_payloads.processed_at)")
      .order('trend_date ASC')
      .where("date_trunc('week', test_payloads.processed_at) >= ?", weeks.weeks.ago.at_beginning_of_week)

    # Collect the results trend
    res[:results_trend] = []
    (0..weeks - 1).each do |week_idx|
      week_date = (week_idx + 1).weeks.ago.at_beginning_of_week

      # Try to find the data for the current week date
      week_trend = results_trends_count.find{ |trend| trend.trend_date == week_date }

      # Check if the DB returned data for the week date, otherwise consider as 0
      res[:results_trend] << (week_trend.nil? ? 0 : week_trend.test_results_count)
    end

    res
  end
end
class PlatformTableInfo
  attr_accessor :name, :rows, :rows_trend, :table_size, :indexes_size, :total_size

  def initialize(table_stats)
    @name = table_stats['name']
    @rows = table_stats['count'].to_i
    @rows_trend = table_stats['count_trend']
    @table_size = table_stats['table_size'].to_i
    @indexes_size = table_stats['indexes_size'].to_i
    @total_size = table_stats['total_size'].to_i
  end

  def self.stats(trends_weeks: 5)
    # This query retrieve all the table where the column created_at is present
    created_at_tables_sql = %{
      SELECT
        c.relname AS name
      FROM
        pg_class AS c
      INNER JOIN
        pg_attribute AS a on a.attrelid = c.oid
      WHERE
        a.attname = 'created_at'
        AND c.relkind = 'r'
    }

    starting_date = trends_weeks.weeks.ago.at_beginning_of_week

    # We want to build the SQL queries to count the rows in the retrieved tables
    rows_count_queries = {}
    ActiveRecord::Base.connection.execute(created_at_tables_sql).to_a.each do |row|
      # We do an exception for test results table to make some performance improvement
      rows_count_queries[row['name']] = if row['name'] == 'test_results'
        Organization
          .select("
            SUM(test_payloads.results_count) AS count,
            date_trunc('week', test_payloads.processed_at) AS trend_date
          ")
          .joins('
            LEFT OUTER JOIN "projects" ON "projects"."organization_id" = "organizations"."id"
            LEFT OUTER JOIN "project_versions" ON "project_versions"."project_id" = "projects"."id"
            LEFT OUTER JOIN "test_payloads" ON "test_payloads"."project_version_id" = "project_versions"."id"
          ')
          .group("date_trunc('week', test_payloads.processed_at)")
          .order('trend_date ASC')
          .where("date_trunc('week', test_payloads.processed_at) >= ?", starting_date)
      else
        # We build the SQL query
        %{
          SELECT
            COUNT(created_at) AS count,
            date_trunc('week', created_at) AS trend_date
          FROM
            #{row['name']}
          WHERE
            created_at >= $1
          GROUP BY
            date_trunc('week', created_at)
          ORDER BY
            trend_date ASC
        }
      end
    end

    # Global query to get approximations of the database metrics (rows and disk space)
    db_stats_sql = %{
      SELECT
        short_table_name AS name,
        pg_table_size(table_name) AS table_size,
        pg_indexes_size(table_name) AS indexes_size,
        pg_total_relation_size(table_name) AS total_size,
        (SELECT reltuples::BIGINT FROM pg_class WHERE relname=short_table_name) AS count
      FROM (
        SELECT
          table_name AS short_table_name,
          ('"' || table_schema || '"."' || table_name || '"') AS table_name
        FROM
          information_schema.tables
        WHERE
          table_schema LIKE 'public'
      ) AS all_tables
      ORDER BY total_size DESC, name ASC
    }

    # Consolidate the stats data by adding the rows count for the trend
    ActiveRecord::Base.connection.execute(db_stats_sql).to_a.collect do |table_stats|
      # Try to retrieve the count query for the current table
      count_query = rows_count_queries[table_stats['name']] unless rows_count_queries[table_stats['name']].nil?

      # Check there is a count query
      if count_query
        # Check if the count query is native SQL or through an active record
        counts_trend = if count_query.kind_of?(String)
          # The bind (third arg of exec_query) expect to have an array of array
          # http://stackoverflow.com/a/21414629
          ActiveRecord::Base.connection.exec_query(count_query, "count_#{table_stats['name']}", [[nil, starting_date ]]).to_a
        else
          count_query.to_a
        end

        # Collect the results trend
        table_counts_trend = []
        (0..trends_weeks - 1).each do |week_idx|
          week_date = (week_idx + 1).weeks.ago.at_beginning_of_week

          # Try to find the data for the current week date
          week_trend = counts_trend.find{ |trend| ActiveSupport::TimeWithZone.new(trend['trend_date'], week_date.time_zone) == week_date }

          # Check if the DB returned data for the week date, otherwise consider as 0
          table_counts_trend << (week_trend.nil? ? 0 : week_trend['count'].to_i)
        end

        table_stats['count_trend'] = table_counts_trend
      end

      PlatformTableInfo.new(table_stats)
    end
  end
end
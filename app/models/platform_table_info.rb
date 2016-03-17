class PlatformTableInfo
  attr_accessor :name, :rows, :table_size, :indexes_size, :total_size

  def initialize(table_stats)
    @name = table_stats['name']
    @rows = table_stats['count'].to_i
    @table_size = table_stats['table_size'].to_i
    @indexes_size = table_stats['indexes_size'].to_i
    @total_size = table_stats['total_size'].to_i
  end

  def self.stats
    sql = 'SELECT' +
      ' short_table_name AS name,' +
      ' pg_table_size(table_name) AS table_size,' +
      ' pg_indexes_size(table_name) AS indexes_size,' +
      ' pg_total_relation_size(table_name) AS total_size,' +
      ' (SELECT reltuples::BIGINT FROM pg_class WHERE relname=short_table_name) AS count' +
    ' FROM (' +
      'SELECT' +
        ' table_name AS short_table_name,' +
        ' (\'"\' || table_schema || \'"."\' || table_name || \'"\') AS table_name' +
      ' FROM information_schema.tables' +
      ' WHERE table_schema LIKE \'public\'' +
    ') AS all_tables' +
    ' ORDER BY total_size DESC'

    ActiveRecord::Base.connection.execute(sql).to_a.collect { |table_stats| PlatformTableInfo.new(table_stats) }
  end
end
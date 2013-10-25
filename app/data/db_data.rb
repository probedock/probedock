# Copyright (c) 2012-2013 Lotaris SA
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

class DbData

  def self.compute
    JsonCache.new(:db_status, expire: 30.minutes){ compute_data.deep_stringify_keys! }
  end

  private

  def self.compute_data
    {
      main: main_database_size,
      cache: cache_database_size
    }
  end

  def self.main_database_size
    config = HashWithIndifferentAccess.new Rails.configuration.database_configuration[Rails.env]
    database_name = config[:database]
    case config[:adapter]
    when /mysql/
      sql = "select FORMAT(SUM(data_length + index_length), 0) as bytes from information_schema.TABLES where table_schema = '#{database_name}'"
      ActiveRecord::Base.connection.execute(sql).to_a[0][0].gsub(/[^0-9]/, '').to_i
    when /postgres/
      sql = "SELECT pg_size_pretty(pg_database_size('#{database_name}'));"
      ActiveRecord::Base.connection.execute(sql).to_a[0][0].to_i
    end
  end

  def self.cache_database_size
    $redis.info['used_memory'].to_i
  end
end

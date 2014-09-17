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
class GeneralData
  # TODO: spec general data

  def self.compute params = {}
    options = {
      settings: params.delete(:settings)
    }
    GeneralDataBuilder.new(params, options).build
  end

  def self.clear
    $redis.del CACHE_KEY
  end

  private

  CACHE_KEY = 'cache:general'

  # TODO: expire db size cache every X minutes rather than for every payload
  include RoxHook
  on('api:payload', 'purged:testRuns'){ $redis.hdel CACHE_KEY, [ :db_main, :db_cache, :count_tests, :count_runs, :count_results ] }
  on('user:created', 'user:destroyed'){ $redis.hdel CACHE_KEY, [ :count_users ] }
  on('test:deprecated', 'test:undeprecated'){ $redis.hdel CACHE_KEY, [ :tests_failing, :tests_inactive, :tests_outdated, :tests_deprecated ] }
  on('settings:app:saved'){ $redis.hdel CACHE_KEY, [ :tests_outdated, :tests_outdatedDays ] }

  class GeneralDataBuilder

    def initialize params, options = {}
      @params = params
      @settings = options[:settings]
    end

    def build

      @added = []
      @settings ||= Settings.app
      @cache = $redis.hgetall CACHE_KEY
      @data = { app: {}, db: {}, count: {}, tests: {}, jobs: {} }

      add(:app, :environment, cache: false){ Rails.env }
      add(:app, :startedAt, transform: :to_i, cache: false){ Rails.application.started_at.to_ms }

      add(:db, :main, transform: :to_i){ main_database_size }
      add(:db, :cache, transform: :to_i){ cache_database_size }

      add(:count, :users, transform: :to_i){ User.count }
      add(:count, :tests, transform: :to_i){ TestInfo.count }
      add(:count, :runs, transform: :to_i){ TestRun.count }
      add(:count, :results, transform: :to_i){ TestResult.count }

      add(:tests, :failing, transform: :to_i){ TestInfo.failing.count }
      add(:tests, :inactive, transform: :to_i){ TestInfo.inactive.count }
      add(:tests, :outdated, transform: :to_i){ TestInfo.outdated(@settings).count }
      add(:tests, :outdatedDays, transform: :to_i){ @settings.test_outdated_days }
      add(:tests, :deprecated, transform: :to_i){ TestInfo.deprecated.count }

      resque = Resque.info if @params[:jobs]
      [ :workers, :working, :pending, :processed ].each do |name|
        add_raw(:jobs, name){ resque[name] }
      end
      add_raw(:jobs, :failed){ Resque::Failure.count }

      $redis.hmset CACHE_KEY, *@added if @added.present?

      @data.select{ |k,v| v.present? }
    end

    private

    def true? value
      (value && !!value == value) || value.kind_of?(String)
    end

    def add_raw category, name, &block
      if true?(@params[category]) or true?(@params[category].try(:[], name))
        @data[category][name] = block.call
      end
    end

    def add category, name, options = {}, &block

      transformation = options[:transform]

      if true?(@params[category]) or true?(@params[category].try(:[], name))
        key = "#{category}_#{name}"
        @data[category][name] = if cached = @cache[key]
          transformation ? cached.send(transformation) : cached
        else
          block.call.tap do |value|
            @added << key << value if options.fetch :cache, true
          end
        end
      end
    end

    def main_database_size
      config = HashWithIndifferentAccess.new Rails.configuration.database_configuration[Rails.env]
      database_name = config[:database]
      case config[:adapter]
      when /mysql/
        sql = "select FORMAT(SUM(data_length + index_length), 0) as bytes from information_schema.TABLES where table_schema = '#{database_name}'"
        ActiveRecord::Base.connection.execute(sql).to_a[0][0].gsub(/[^0-9]/, '').to_i
      when /postgres/
        sql = "SELECT pg_size_pretty(pg_database_size('#{database_name}'));"
        ActiveRecord::Base.connection.execute(sql).to_a[0][0].to_i
      else
        -1
      end
    end

    def cache_database_size
      $redis.info['used_memory'].to_i
    end
  end
end

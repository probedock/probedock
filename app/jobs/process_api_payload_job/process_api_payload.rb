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
require 'benchmark'

class ProcessApiPayloadJob

  class ProcessApiPayload
    attr_reader :processed_test_run, :user, :time_received, :cache

    def initialize data, user_id, time_received

      @user = User.find user_id
      @time_received = Time.at Rational(time_received)
      Rails.logger.info "Starting to process payload received at #{@time_received}"

      time = Benchmark.realtime do

        data = HashWithIndifferentAccess.new data

        TestRun.transaction do

          @cache = self.class.build_cache data, @time_received
          @processed_test_run = ProcessApiTestRun.new data, @user, @time_received, @cache

          # Mark test keys as used.
          free_keys = @cache[:keys].select &:free?
          TestKey.where(id: free_keys.collect(&:id)).update_all free: false if free_keys.any?
        end
      end

      duration = (time * 1000).round 1
      number_of_test_results = data[:r].inject(0){ |memo,results| memo + results[:t].length }
      Rails.logger.info "Processed API payload with #{number_of_test_results} test results in #{duration}ms"

      ROXCenter::Application.events.fire 'api:payload', self
    end

    private

    def self.build_cache data, time_received
      Hash.new.tap do |cache|

        time = Benchmark.realtime do

          projects = Project.where(api_id: data[:r].collect{ |r| r[:j] }).to_a
          cache[:projects] = projects
          cache[:project_versions] = build_project_versions_cache data, projects

          keys_by_project = data[:r].inject({}){ |memo,results| memo[results[:j]] = results[:t].collect{ |t| t[:k] }; memo }
          cache[:keys] = TestKey.for_projects_and_keys(keys_by_project).includes([ :user, :project, { test_info: [ :deprecation, :tags, :tickets ] } ]).to_a
          cache[:tests] = cache[:keys].collect(&:test_info).compact
          cache[:deprecations] = build_deprecations_cache cache[:tests], time_received

          custom_value_names = data[:r].inject([]){ |memo,results| results[:t].each{ |test| memo.concat test[:a].keys if test[:a].present? }; memo }
          cache[:custom_values] = TestValue.select('id, name, test_info_id').where(name: custom_value_names, test_info_id: cache[:tests].collect(&:id))

          cache[:run] = TestRun.where('LOWER(uid) IN (?)', data[:u].downcase).first if data[:u].present?

          cache[:categories] = build_categories_cache data
          cache[:tags] = build_tags_cache data
          cache[:tickets] = build_tickets_cache data
        end

        Rails.logger.info "Cached payload data in #{(time * 1000).round 1}ms"
      end
    end

    def self.build_deprecations_cache tests, time_received
      return [] if tests.empty?
      TestDeprecation.select('id, test_info_id, created_at, deprecated').where('test_info_id IN (?) AND created_at >= ?', tests.collect{ |t| t.id }, time_received).to_a
    end

    def self.build_categories_cache data
      category_names = data[:r].inject([]){ |memo,results| memo.concat results[:t].collect{ |test| test[:c] } }.select(&:present?).uniq{ |name| name.downcase }
      Category.where('LOWER(name) IN (?)', category_names.collect(&:downcase)).to_a.tap do |categories|
        category_names.reject{ |name| categories.find{ |cat| cat.name.downcase == name.downcase } }.each do |name|
          categories << Category.new.tap{ |cat| cat.name = name; cat.quick_validation = true; cat.save! }
        end
      end
    end

    def self.build_tags_cache data
      tags = data[:r].inject([]){ |memo,results| results[:t].each{ |test| memo.concat test[:g] if test[:g].present? }; memo }.select(&:present?).uniq{ |name| name.downcase }
      existing_tags = Tag.where('LOWER(name) IN (?)', tags.collect(&:downcase))
      tags.collect{ |name| existing_tags.find{ |tag| tag.name.downcase == name.downcase } || Tag.new.tap{ |t| t.name = name; t.quick_validation = true; t.save! } }
    end

    def self.build_tickets_cache data
      tickets = data[:r].inject([]){ |memo,results| results[:t].each{ |test| memo.concat test[:t] if test[:t].present? }; memo }.select(&:present?).uniq{ |name| name.downcase }
      existing_tickets = Ticket.where('LOWER(name) IN (?)', tickets.collect(&:downcase))
      tickets.collect{ |name| existing_tickets.find{ |ticket| ticket.name.downcase == name.downcase } || Ticket.new.tap{ |t| t.name = name; t.quick_validation = true; t.save! } }
    end

    def self.build_project_versions_cache data, projects

      versions_by_project = data[:r].inject({}){ |memo,results| memo[projects.find{ |p| p.api_id == results[:j] }.id] = results[:v]; memo }

      conditions, values = [], []
      versions_by_project.each_pair do |project_id,version_name|
        conditions << "project_id = ? AND LOWER(name) = ?"
        values << project_id << version_name.downcase
      end

      ProjectVersion.where(*values.unshift(conditions.join(' OR '))).to_a.tap do |versions|
        versions.each{ |v| versions_by_project.delete v.project_id }
        versions_by_project.each do |project_id,version_name|
          versions << ProjectVersion.new.tap{ |v| v.project_id = project_id; v.name = version_name; v.quick_validation = true; v.save! }
        end
      end
    end
  end
end

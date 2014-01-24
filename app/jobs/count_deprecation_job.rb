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
class CountDeprecationJob
  @queue = 'metrics:test_counters'

  include RoxHook
  on('test:deprecated', 'test:undeprecated'){ |deprecation| enqueue_deprecations(Array.wrap(deprecation), timezones: ROXCenter::Application.metrics_timezones) }

  def self.enqueue_deprecations deprecations, options = {}
    Rails.logger.debug "Updating test counters for #{deprecations.length} deprecations in background job"
    Resque.enqueue self, deprecations.collect(&:id), options
  end

  def self.perform deprecation_ids, options = {}
    options = HashWithIndifferentAccess.new options

    deprecations = TestDeprecation.includes(test_info: [ :project, :author ], test_result: [ :category ]).find deprecation_ids
    deprecations.each{ |deprecation| new deprecation, options }

    Rails.application.events.fire 'test:counters'
  end

  def initialize deprecation, options = {}
    raise ":timezones option is missing" if !options[:timezones].kind_of?(Array)

    project = deprecation.test_info.project
    user = deprecation.test_info.author
    category = deprecation.test_result.category

    @counter_base = { cache: {}, time: deprecation.created_at, deprecated: deprecation.deprecated ? 1 : -1 }
    options[:timezones].each do |timezone|
      @counter_base[:timezone] = timezone

      count_deprecation
      count_deprecation project: project
      count_deprecation project: project, category: category
      count_deprecation project: project, user: user
      count_deprecation category: category
      count_deprecation category: category, user: user
      count_deprecation user: user
    end
  end

  private

  def count_deprecation options = {}
    TestCounter.measure @counter_base.merge(options)
  end
end

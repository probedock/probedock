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
  on('test:deprecated', 'test:undeprecated'){ |deprecation| enqueue_deprecation deprecation, timezones: ROXCenter::Application.metrics_timezones }

  def self.enqueue_deprecation deprecation, options = {}
    Rails.logger.debug "Updating test counters for deprecation (#{deprecation.deprecated}) of test #{deprecation.test_info_id} at #{deprecation.created_at} in background job"
    Resque.enqueue self, deprecation.id, options
  end

  def self.perform deprecation_id, options = {}
    options = HashWithIndifferentAccess.new options

    deprecation = TestDeprecation.includes(test_info: [ :project, :author ], test_result: [ :category ]).find deprecation_id

    new deprecation, options

    Rails.application.events.fire 'test:counters'
  end

  def initialize deprecation, options = {}
    raise ":timezones option is missing" if !options[:timezones].kind_of?(Array)

    project = deprecation.test_info.project
    user = deprecation.test_info.author
    category = deprecation.test_result.category

    @counter_base = { cache: {}, time: deprecation.created_at, written: deprecation.deprecated ? -1 : 1 }
    options[:timezones].each do |timezone|
      @counter_base[:timezone] = timezone

      count_write
      count_write project: project
      count_write project: project, category: category
      count_write project: project, user: user
      count_write category: category
      count_write category: category, user: user
      count_write user: user
    end
  end

  private

  def count_write options = {}
    TestCounter.measure @counter_base.merge(options)
  end
end

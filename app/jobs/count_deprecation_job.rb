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

class CountDeprecationJob
  @queue = 'metrics:test_counters'

  include RoxHook
  on('test:deprecated', 'test:undeprecated'){ |test| enqueue_test test, timezones: ROXCenter::Application.metrics_timezones }

  def self.enqueue_test test, options = {}
    deprecated, time = !!test.deprecated_at, (test.deprecated_at || test.updated_at)
    Rails.logger.debug "Updating test counters for deprecation (#{deprecated}) of test #{test.id} at #{time} in background job"
    Resque.enqueue self, test.id, time.to_r.to_s, deprecated, options
  end

  def self.perform test_id, time_string, deprecated, options = {}
    options = HashWithIndifferentAccess.new options

    test = TestInfo.select('id, project_id, category_id, author_id').includes(:project, :category, :author).find test_id
    time = Time.at Rational(time_string)

    new test, time, deprecated, options

    ROXCenter::Application.events.fire 'test:counters'
  end

  def initialize test, time, deprecated, options = {}
    raise ":timezones option is missing" if !options[:timezones].kind_of?(Array)

    following_result = TestResult.select('previous_category_id').where('test_info_id = ? AND run_at >= ?', test.id, time).order('run_at ASC').limit(1).first

    project = test.project
    user = test.author
    category = following_result ? following_result.previous_category : test.category

    @counter_base = { cache: {}, time: time, written: deprecated ? -1 : 1 }
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

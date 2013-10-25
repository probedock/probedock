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

class CacheReportJob
  @queue = 'cache'

  include RoxHook
  on('api:payload'){ |job| enqueue job.processed_test_run.test_run }

  def self.enqueue test_run
    Rails.logger.debug "Caching report for test run #{test_run.id} in background job"
    Resque.enqueue self, test_run.id, cache: :force
  end

  def self.perform test_run_id, options = {}
    TestRun.reports_cache.get test_run_id, HashWithIndifferentAccess.new(options)
  end
end

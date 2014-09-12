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
require 'resque/plugins/workers/lock'

class PurgeJob
  # TODO: use resque-throttle to ensure this job can only be queued once per hour
  extend Resque::Plugins::Workers::Lock

  @queue = :purge

  def self.perform
    Resque.enqueue PurgeTagsJob if last_purge_outdated(:tags) && PurgeTagsJob.unused_tags.count >= 1
    Resque.enqueue PurgeTicketsJob if last_purge_outdated(:tickets) && PurgeTicketsJob.unused_tickets.count >= 1
    Resque.enqueue PurgeTestPayloadsJob if last_purge_outdated(:test_payloads) && PurgeTestPayloadsJob.outdated_payloads.count >= 1
  end

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers *args
    name # the same lock (class name) is used for all workers
  end

  private

  def last_purge_outdated data_type
    previous_purge = PurgeAction.previous_for data_type
    previous_purge.blank? || Time.now - previous_purge.created_at > 60.days
  end
end

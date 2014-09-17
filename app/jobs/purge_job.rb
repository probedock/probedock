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
  include RoxHook

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers *args
    name # the same lock (class name) is used for all workers
  end

  def self.perform purge_action_id
    PurgeAction.transaction do
      purge_action = PurgeAction.find purge_action_id
      perform_purge purge_action
      Rails.application.events.fire "purged:#{purge_action.data_type}"
    end
  end

  private

  def self.complete_purge! purge, number_purged
    purge.number_purged = number_purged
    purge.completed_at = Time.now
    purge.remaining_jobs = 0
    purge.save!
  end
end

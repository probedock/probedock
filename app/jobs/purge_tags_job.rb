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

class PurgeTagsJob < PurgeJob
  extend Resque::Plugins::Workers::Lock
  @queue = :purge

  def self.perform_purge purge_action

    start = Time.now

    n = unused_tags.delete_all
    complete_purge! purge_action, n

    Rails.logger.info "Purged #{n} unused tags in #{(Time.now - start).to_f.round 3}s"
  end

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers *args
    ProcessNextTestPayloadJob.name # use the same lock as payload processing
  end

  def self.number_remaining
    unused_tags.count
  end

  private

  def self.unused_tags
    Tag.select('distinct tags.id').joins('LEFT OUTER JOIN tags_test_infos ON tags.id = tags_test_infos.tag_id').where('tags_test_infos.test_info_id IS NULL')
  end
end

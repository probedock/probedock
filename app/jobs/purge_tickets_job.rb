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

class PurgeTicketsJob
  extend Resque::Plugins::Workers::Lock

  @queue = :purge

  def self.perform
    n = unused_tickets.delete_all
    Rails.logger.info "Purged #{n} unused tickets"
    Rails.application.events.fire 'purge:tickets'
  end

  def self.purge_id
    :tickets
  end

  def self.purge_info
    {
      id: :tickets,
      total: unused_tickets.count.length
    }
  end

  def self.unused_tickets
    Ticket.select('tickets.id').joins('LEFT OUTER JOIN test_infos_tickets ON tickets.id = test_infos_tickets.ticket_id').where('test_infos_tickets.test_info_id IS NULL').group('tickets.id')
  end

  # resque-workers-lock: lock workers to prevent concurrency
  def self.lock_workers *args
    ProcessNextTestPayloadJob.name # use the same lock as payload processing
  end
end

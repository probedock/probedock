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
class PurgeTestPayloadsJob
  @queue = :purge

  def self.perform
    n = outdated_payloads(Settings.app.test_payloads_lifespan).delete_all
    Rails.logger.info "Purged #{n} outdated test payloads"
    Rails.application.events.fire 'purge:payloads'
  end

  def self.purge_id
    :payloads
  end

  def self.purge_info
    lifespan = Settings.app.test_payloads_lifespan
    {
      id: :payloads,
      lifespan: lifespan * 24 * 3600 * 1000,
      total: outdated_payloads(lifespan).count
    }
  end

  private

  def self.outdated_payloads lifespan
    TestPayload.where(state: :processed).where 'received_at < ?', Time.now - lifespan * 24 * 3600
  end
end

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
class PurgeTestPayloadsJob < PurgeJob
  @queue = :purge

  def self.perform_purge purge_action

    start = Time.now

    n = outdated_payloads(Settings.app.test_payloads_lifespan).delete_all
    complete_purge! purge_action, n

    Resque.logger.info "Purged #{n} outdated test payloads in #{(Time.now - start).to_f.round 3}s"
  end

  def self.data_lifespan
    Settings.app.test_payloads_lifespan
  end

  def self.number_remaining
    outdated_payloads(Settings.app.test_payloads_lifespan).count
  end

  private

  def self.outdated_payloads lifespan
    TestPayload.where(state: :processed).where 'received_at < ?', Time.now - lifespan * 24 * 3600
  end
end

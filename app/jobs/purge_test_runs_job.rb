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
class PurgeTestRunsJob < PurgeJob
  @queue = :purge

  def self.perform_purge purge_action

    start = Time.now

    n = outdated_test_runs(Settings.app.test_runs_lifespan).delete_all
    complete_purge! purge_action, n

    Rails.logger.info "Purged #{n} outdated test runs in #{(Time.now - start).to_f.round 3}s"
  end

  def self.data_lifespan
    Settings.app.test_runs_lifespan
  end

  def self.number_remaining
    outdated_test_runs(Settings.app.test_runs_lifespan).count
  end

  private

  def self.outdated_test_runs lifespan
    TestRun.where 'ended_at < ?', Time.now - lifespan * 24 * 3600
  end
end

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
class LatestTestRunsData
  GROUP_LIMIT = 3

  def self.compute
    JsonCache.new(:latest_test_runs){ compute_data.deep_stringify_keys! }
  end

  private

  def self.compute_data
    rel = TestRun.order('ended_at DESC').includes(:runner)
    ended_at_desc = Proc.new{ |a,b| b.ended_at <=> a.ended_at }

    latest_for_groups = TestRun.groups.collect{ |name| rel.where(group: name).limit(1).first }.compact.sort(&ended_at_desc).first(GROUP_LIMIT)
    latest_for_users = rel.joins(:runner_as_last_run).where('users.roles_mask & ? = 0 AND test_runs.id NOT IN (?)', User.mask_for(:technical), latest_for_groups.collect(&:id)).to_a

    latest_for_groups.collect{ |r| r.to_client_hash type: :latest_group } + latest_for_users.collect{ |r| r.to_client_hash type: :latest }
  end
end

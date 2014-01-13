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
class LatestProjectsData
  LIMIT = 5

  include RoxHook
  on 'api:payload' do |job|
    JsonCache.clear :latest_projects
  end

  def self.compute
    JsonCache.new(:latest_projects, etag: false){ compute_data.deep_stringify_keys! }
  end

  private

  def self.compute_data
    Project.joins(:tests).select('projects.name, projects.url_token, max(test_infos.created_at)').group('projects.id').order('max(test_infos.created_at) DESC').limit(LIMIT).collect do |p|
      { name: p.name, url_token: p.url_token }
    end
  end
end

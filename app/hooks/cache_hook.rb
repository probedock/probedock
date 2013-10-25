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
require 'hooks'

class CacheHook
  include RoxHook

  on 'api:payload' do |job|
    # FIXME: centralize caches and event clearing (caches should be hooks)
    JsonCache.clear :tag_cloud, :tests_status, :latest_test_runs, :latest_projects
  end

  on 'test:deprecated', 'test:undeprecated' do
    JsonCache.clear :tests_status
  end
end

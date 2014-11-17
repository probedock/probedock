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
module ROXCenter
  class MetricsApi < Grape::API

    namespace :metrics do

      before do
        authenticate!
      end

      get :newTests do

        rel = ProjectTest.select("count(project_tests.id) as project_tests_count, date_trunc('day', created_at) as project_tests_day")
        rel = rel.where 'created_at >= ?', 30.days.ago
        rel = rel.group('project_tests_day').order('project_tests_day').limit(7)

        rel.to_a.collect do |data|
          {
            date: data.project_tests_day.strftime('%Y-%m-%d'),
            testsCount: data.project_tests_count
          }
        end
      end
    end
  end
end

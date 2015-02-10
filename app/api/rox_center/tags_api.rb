# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of Probe Dock.
#
# Probe Dock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Probe Dock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.
module ROXCenter
  class TagsApi < Grape::API

    namespace :tags do

      before do
        authenticate!
      end

      get do

        pageSize = params[:pageSize].to_i
        pageSize = Settings.app.tag_cloud_size if pageSize < 1

        Tag.select('tags.name, count(distinct project_tests.id) as tests_count').joins(test_descriptions: :test).group('tags.name').order('count(distinct project_tests.id) desc').limit(pageSize).having('count(distinct project_tests.id) > 0').to_a.collect do |tag|
          { name: tag.name, testsCount: tag.tests_count }
        end
      end
    end
  end
end

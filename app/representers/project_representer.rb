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
class ProjectRepresenter < BaseRepresenter

  representation do |project|

    link 'self', api_uri(:project, id: project.api_id)

    %w(name api_id url_token deprecated_tests_count).each do |name|
      property name.camelize(:lower), project.send(name)
    end

    # TODO: rename activeTestsCount to testsCount or currentTestsCount to avoid confusion with active/inactive tests
    property :activeTestsCount, project.tests_count - project.deprecated_tests_count

    %w(created_at).each do |name|
      property name.camelize(:lower), project.send(name).to_i * 1000
    end
  end
end

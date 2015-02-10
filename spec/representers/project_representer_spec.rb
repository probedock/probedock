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
require 'spec_helper'

describe ProjectRepresenter, probe_dock: { tags: :unit } do

  let(:project){ create :project, tests_count: 3, deprecated_tests_count: 1 }
  subject{ ProjectRepresenter.new(project).serializable_hash }

  it(nil, probe_dock: { key: '927ffaa9b765' }){ should hyperlink_to('self', api_uri(:project, id: project.api_id)) }

  it(nil, probe_dock: { key: 'ddaf8ad424d5' }) do
    should have_only_properties({
      name: project.name,
      apiId: project.api_id,
      urlToken: project.url_token,
      activeTestsCount: project.tests_count - project.deprecated_tests_count,
      deprecatedTestsCount: project.deprecated_tests_count,
      createdAt: project.created_at.to_ms
    })
  end
end

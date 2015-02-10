# Copyright (c) 2015 42 inside
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

describe LegacyProjectsRepresenter, probe_dock: { tags: :unit } do

  let(:projects){ Array.new(3){ create :project } }
  let(:options){ { total: 5, data: projects } }
  subject{ described_class.new(OpenStruct.new(options)).serializable_hash }

  it(nil, probe_dock: { key: 'a45e0494f59b' }){ should hyperlink_to('self', api_uri(:legacy_projects)) }
  it(nil, probe_dock: { key: 'edcb4fd3a78a' }){ should have_embedded('v1:projects', projects.collect{ |p| ProjectRepresenter.new(p).serializable_hash }) }
  it(nil, probe_dock: { key: 'd3cf50f0d1b9' }){ should have_only_properties(total: 5) }
  it(nil, probe_dock: { key: 'd9aa8139df72' }){ should have_curie(name: 'v1', templated: true, href: "#{uri(:doc_api_relation, name: 'v1:')}projects:{rel}") }

  context "with a page number" do
    let(:options){ super().merge page: 1 }

    it(nil, probe_dock: { key: '2525dd784941' }){ should have_only_properties(total: 5, page: 1) }
  end
end

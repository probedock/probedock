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
class TestInfoRepresenter < BaseRepresenter

  representation do |test_info|

    curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:tests:{rel}", templated: true

    link 'bookmark', uri(:test_permalink, project: test_info.project.api_id, key: test_info.key.key), type: media_type(:html)

    property :name, test_info.name
    property :passing, test_info.passing
    property :active, test_info.active
    property :createdAt, test_info.created_at.to_ms
    property :lastRunAt, test_info.last_run_at.to_ms
    property :deprecatedAt, test_info.deprecation.created_at if test_info.deprecation

    embed('v1:author', test_info.author){ |author| UserRepresenter.new author }
    embed('v1:project', test_info.project){ |project| ProjectRepresenter.new project }
    embed('v1:category', test_info.category){ |category| CategoryRepresenter.new category }
    embed_collection('v1:tags', test_info.tags){ |tag| TagRepresenter.new tag }
    embed_collection('v1:tickets', test_info.tickets){ |ticket| TicketRepresenter.new ticket }
  end
end

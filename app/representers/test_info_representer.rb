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

    link 'self', api_uri(:test, id: test_info.to_param)
    link 'alternate', uri(:test_info, id: test_info.to_param), type: media_type(:html)
    link 'bookmark', uri(:test_permalink, project: test_info.project.api_id, key: test_info.key.key), type: media_type(:html)
    link 'v1:deprecation', uri(:deprecation_api_test, id: test_info.to_param)
    link 'v1:testResults', uri(:results_api_test, id: test_info.to_param)
    link 'v1:projectVersions', uri(:project_versions_api_test, id: test_info.to_param)

    property :name, test_info.name
    property :key, test_info.key.key
    property :passing, test_info.passing
    property :active, test_info.active
    property :createdAt, test_info.created_at.to_ms
    property :deprecatedAt, test_info.deprecation.created_at if test_info.deprecation
    property :lastRunAt, test_info.last_run_at.to_ms
    property :lastRunDuration, test_info.last_run_duration
    property :runCount, test_info.results_count

    embed('v1:author', test_info.author){ |author| UserRepresenter.new author }
    embed('v1:project', test_info.project){ |project| ProjectRepresenter.new project }
    embed('v1:category', test_info.category){ |category| CategoryRepresenter.new category } if test_info.category
    embed('v1:lastRunner', test_info.last_runner){ |runner| UserRepresenter.new runner }

    if test_info.effective_result.present?
      embed('v1:lastRun', test_info.effective_result.test_run){ |run| TestRunRepresenter.new run }
    end

    embed_collection('v1:tags', test_info.tags){ |tag| TagRepresenter.new tag }
    embed_collection('v1:tickets', test_info.tickets){ |ticket| TicketRepresenter.new ticket }
  end
end

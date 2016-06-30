# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
require 'resque/plugins/workers/lock'

class ImportElasticTestResultsJob

  @queue = :low

  def self.perform organization_id, first_id, last_id

    rel = TestResult.joins(project_version: :project).where('test_results.test_id IS NOT NULL AND projects.organization_id = ? AND test_results.id >= ? AND test_results.id <= ?', organization_id, first_id, last_id).includes([ :category, :runner, :tags, :tickets, :test, { key: :user, project_version: { project: :organization } }, test_payload: :test_reports ])

    n = rel.count
    i = 0
    bulk = []

    rel.find_each batch_size: 500 do |result|
      import_result result: result, bulk: bulk, i: i
      i += 1
    end

    import_bulk bulk: bulk if bulk.present?
  end

  def self.import_result result:, bulk:, i:

    bulk << {
      index: {
        _index: ElasticTestResult.index_name.to_s,
        _type: ElasticTestResult.name.underscore,
        _id: result.id,
        data: ElasticTestResult.from_test_result(result).as_json
      }
    }

    if i % 100 == 99
      import_bulk bulk: bulk
    end
  end

  def self.import_bulk bulk:
    ElasticTestResult.gateway.client.bulk body: bulk
    bulk.clear
  end
end

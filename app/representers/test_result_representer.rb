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
class TestResultRepresenter < BaseRepresenter

  representation do |result,res,options|

    curie 'v1', "#{uri(:doc_api_relation, name: 'v1')}:testResults:{rel}", templated: true

    link 'self', api_uri(:test_result, id: result.id)

    property :passed, result.passed
    property :active, result.active
    property :duration, result.duration
    property :version, result.project_version.name
    property :runAt, result.run_at.to_ms
    property :message, result.message if options.try(:[], :detailed) and result.message.present?

    embed('v1:runner', result.runner){ |runner| UserRepresenter.new runner }
    embed('v1:testRun', result.test_run){ |run| TestRunRepresenter.new run }
  end
end

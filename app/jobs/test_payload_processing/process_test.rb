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
module TestPayloadProcessing
  class ProcessTest
    attr_reader :test

    def initialize project_version, key, test, results

      new_test = test.nil?
      project = project_version.project
      last_name = results.last.name

      if new_test
        test = ProjectTest.new(key: key, project: project, name: last_name, first_run_at: results.first.run_at, first_runner: results.first.runner).tap(&:save_quickly!)
        key.test = test if key
      elsif key
        test.key = key
      end

      description = new_test ? nil : test.descriptions.where(project_version_id: project_version.id).includes(:project_version).first
      new_description = description.blank?

      if new_description
        description = TestDescription.new test: test, project_version: project_version
      end

      description.name = last_name
      description.passing = results.none?{ |r| !r.passed }
      description.active = results.any?{ |r| r.active }
      description.last_duration = results.last.duration
      description.last_run_at = results.last.run_at
      description.last_runner = results.last.runner
      description.last_result = results.last
      description.category = results.collect(&:category).compact.last
      description.tags = results.inject([]){ |memo,r| memo & r.tags }
      description.tickets = results.inject([]){ |memo,r| memo & r.tickets }
      description.custom_values = results.inject(description.custom_values){ |memo,r| memo.merge r.custom_values }.select{ |k,v| !v.nil? }

      description.results_count += results.length
      description.save!

      # for now, always update test to latest received information
      test.description = description
      test.name = description.name

      # support past results
      test.first_run_at = results.first.run_at if results.first.run_at < test.first_run_at

      test.results_count += results.length
      test.save_quickly!

      TestResult.where(id: results.collect(&:id)).update_all test_id: test.id, new_test: new_test

      @test = test
    end
  end
end

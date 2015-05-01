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
module TestPayloadProcessing
  class ProcessTest
    attr_reader :test

    def initialize test_result, cache

      new_test = test_result.test_id.blank?

      test = if new_test
        created_test = ProjectTest.new(key: test_result.key, project: test_result.project_version.project, name: test_result.name).tap(&:save_quickly!)
        test_result.key.test = created_test if test_result.key
        cache.tests[test_result.name] = created_test unless test_result.key
        created_test
      else
        test_result.test
      end

      description = new_test ? nil : test.descriptions.where(project_version_id: test_result.project_version_id).includes(:project_version).first
      new_description = description.blank?

      if new_description
        description = TestDescription.new test: test, project_version: test_result.project_version
      end

      # TODO: handle client caching (fill name, tags, etc if not given in payload)
      description.name = test_result.name
      description.passing = test_result.passed
      description.active = test_result.active
      description.last_duration = test_result.duration
      description.last_run_at = test_result.run_at
      description.last_runner = test_result.runner
      description.last_result = test_result
      description.category = test_result.category
      description.tags = test_result.tags
      description.tickets = test_result.tickets
      description.custom_values = description.custom_values.merge(test_result.custom_values).select{ |k,v| !v.nil? }

      description.results_count += 1
      description.save!

      # TODO: use semver gem to compare versions
      if !test.description_id || test_result.project_version.name > test.description.project_version.name
        test.description = description
        test.name = description.name
      end

      # TODO: only increment results count once per test
      test.results_count += 1
      test.save_quickly!

      if new_test
        # TODO: only do this once for each test
        TestResult.where(id: test_result.id).update_all test_id: test.id
        # TODO: increment counter once
        Project.increment_counter :tests_count, test_result.project_version.project_id
      end

      @test = test
    end
  end
end

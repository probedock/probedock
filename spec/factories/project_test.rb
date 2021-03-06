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
FactoryGirl.define do
  sequence :project_test_name do |n|
    "test-#{n}"
  end

  factory :project_test, aliases: %w(test) do
    transient do
      last_runner nil
      project_version nil
      category nil
      tags []
      tickets []
    end

    name{ generate :project_test_name }
    project
    first_run_at{ 2.days.ago }

    after :create do |test,evaluator|

      description_options = {
        test: test, last_runner: evaluator.last_runner, project_version: evaluator.project_version,
        category: evaluator.category, tags: evaluator.tags, tickets: evaluator.tickets
      }

      description = create :test_description, description_options
      ProjectTest.where(id: test.id).update_all description_id: description.id

      contributor, kind = if test.key.try(:user).try(:human?)
        [ test.key.user, :key_creator ]
      elsif test.first_runner.try(:human?)
        [ test.first_runner, :first_runner ]
      end

      if contributor
        TestContribution.new(test_description: description, user: contributor, kind: kind).save!
      end
    end
  end
end

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
  factory :test_payload do
    transient do
      random_results false
      test_report nil
    end

    runner
    contents{ MultiJson.dump foo: 'bar' }
    contents_bytesize{ contents.bytesize }
    received_at{ Time.now }
    ended_at{ received_at }
    duration{ rand(10000) + 1 }

    after :create do |payload,evaluator|
      evaluator.test_report.test_payloads << payload if evaluator.test_report

      next unless evaluator.random_results

      random = evaluator.random_results
      n = payload.results_count
      n = rand(25) + 1 if n == 0 && random
      next if n <= 0

      n_passed = random ? n - rand(n) - 1 : payload.passed_results_count
      results_data = Array.new(n){ |i| { passed: i < n_passed } }

      # TODO: generate some inactive results

      results_data.shuffle!
      n.times do |i|
        options = {
          passed: results_data[i][:passed],
          runner: payload.runner,
          project_version: payload.project_version,
          run_at: payload.ended_at,
          test_payload: payload,
          payload_index: i
        }

        create :test_result, options
      end
    end

    factory :processing_test_payload do
      state :processing
      processing_at{ received_at + 1.minute }
    end

    factory :processed_test_payload do
      state :processed
      processing_at{ received_at + 1.minute }
      processed_at{ processing_at + 1.minute }
    end
  end
end

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

  factory :test_run, aliases: [ :run ] do
    runner
    ended_at{ Time.now }
    duration{ rand(120001) }
    results_count 0
    passed_results_count 0
    inactive_results_count 0
    inactive_passed_results_count 0

    factory :test_run_with_uid, aliases: [ :run_with_uid ] do
      uid{ SecureRandom.uuid }
      group 'nightly'
    end
  end
end

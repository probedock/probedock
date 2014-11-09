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
require 'resque/plugins/workers/lock'

module ProcessNextTestResultJob
  extend Resque::Plugins::Workers::Lock

  @queue = :api

  def self.enqueue_test_result test_result

    lock_type, lock_value = if test_result.payload_properties_set?(:key)
      [ :key, test_result.key.key ]
    else
      [ :name, test_result.name ]
    end

    Resque.enqueue self, test_result.id, lock_type, lock_value
  end

  def self.perform test_result_id, *args
    test_result = TestResult.find test_result_id
    test_result.update_attribute :processed, true
    TestPayload.increment_counter :processed_results_count, test_result.test_payload_id
  end

  def self.lock_workers test_result_id, lock_type, lock_value
    "#{lock_type}:#{lock_value}"
  end
end

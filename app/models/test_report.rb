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
class TestReport < ActiveRecord::Base
  include IdentifiableResource
  include QuickValidation

  before_create{ set_identifier :api_id, size: 12 }

  belongs_to :organization
  has_and_belongs_to_many :test_payloads
  has_many :project_versions, through: :test_payloads
  has_many :projects, through: :project_versions
  has_many :results, through: :test_payloads, class_name: 'TestResult'
  has_many :runners, through: :test_payloads, class_name: 'User'

  validates :uid, length: { maximum: 100, allow_blank: true }, uniqueness: { scope: :organization_id }
  validates :organization, presence: true

  %w(duration results_count passed_results_count inactive_results_count inactive_passed_results_count tests_count new_tests_count).each do |method|
    define_method(method){ sum_payload_values method }
  end

  private

  def sum_payload_values method
    test_payloads.inject(0){ |memo,payload| memo + payload.send(method) }
  end
end

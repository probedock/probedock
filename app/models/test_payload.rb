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
class TestPayload < ActiveRecord::Base
  include IdentifiableResource

  before_create{ set_identifier :api_id, :uuid }

  belongs_to :project_version
  belongs_to :runner, class_name: 'User'
  has_many :results, class_name: 'TestResult'
  has_and_belongs_to_many :test_keys
  has_and_belongs_to_many :test_reports

  scope :waiting_for_processing, -> { select((column_names - %w(contents) + [ "contents->'projectId' as raw_project", "contents->'version' as raw_project_version", "contents->'duration' as raw_duration", "contents->'reports' as raw_reports" ])).where(state: :created).order('received_at ASC') }

  include SimpleStates
  states :created, :processing, :processed, :failed
  event :start_processing, from: :created, to: :processing
  event :finish_processing, from: :processing, to: :processed
  event :fail_processing, from: :processing, to: :failed

  validates :runner, presence: true
  validates :project_version, presence: { if: :processed? }
  validates :contents_bytesize, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :state, inclusion: { in: state_names.inject([]){ |memo,name| memo << name << name.to_s } }
  validates :received_at, presence: true
  validates :results_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :passed_results_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :inactive_results_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :inactive_passed_results_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def finish_processing
    test_keys.clear
  end
end

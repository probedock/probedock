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
class TestDescription < ActiveRecord::Base
  include QuickValidation

  # Flags
  INACTIVE = 1

  belongs_to :test, class_name: 'ProjectTest'
  belongs_to :project_version
  belongs_to :last_runner, class_name: 'User'
  belongs_to :last_result, class_name: 'TestResult'
  belongs_to :category
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :tickets
  has_many :contributions, class_name: 'TestContribution'

  strip_attributes
  validates :name, presence: true, length: { maximum: 255 }
  validates :test, presence: { unless: :quick_validation }
  validates :project_version, presence: { unless: :quick_validation }
  validates :passing, inclusion: [ true, false ]
  validates :active, inclusion: [ true, false ]
  validates :last_run_at, presence: true
  validates :last_duration, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_blank: true }
  validates :last_runner, presence: { unless: :quick_validation }

  def custom_values
    read_attribute(:custom_values) || {}
  end
end

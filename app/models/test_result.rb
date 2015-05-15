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
class TestResult < ActiveRecord::Base
  include JsonResource
  include QuickValidation

  belongs_to :test, class_name: 'ProjectTest'
  belongs_to :key, class_name: 'TestKey'
  belongs_to :runner, class_name: 'User'
  belongs_to :test_payload
  belongs_to :project_version
  belongs_to :category
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :tickets
  has_and_belongs_to_many :test_reports

  bitmask :payload_properties_set, as: [ :key, :name, :category, :tags, :tickets, :custom_values ], null: false

  strip_attributes
  validates :name, length: { maximum: 255, allow_blank: true }
  validates :passed, inclusion: [ true, false ]
  validates :duration, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :message, length: { maximum: 65535, tokenizer: lambda{ |s| s.bytes.to_a } } # byte length
  validates :active, inclusion: [ true, false ]
  validates :run_at, presence: true
  validates :runner, presence: { unless: :quick_validation }
  validates :test, presence: { unless: :quick_validation }
  validates :test_payload, presence: { unless: :quick_validation }
  validates :project_version, presence: { unless: :quick_validation }

  def passed?
    passed
  end

  def active?
    active
  end

  def custom_values
    read_attribute(:custom_values) || {}
  end
end

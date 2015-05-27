# Copyright (c) 2015 ProbeDock
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
class TestKey < ActiveRecord::Base
  include JsonResource
  include QuickValidation

  before_create :set_value
  before_destroy :ensure_no_test_payloads

  belongs_to :user
  belongs_to :project
  has_one :test, class_name: 'ProjectTest', foreign_key: :key_id
  has_many :test_results, foreign_key: :key_id
  has_and_belongs_to_many :test_payloads

  strip_attributes
  validates :key, uniqueness: { scope: :project_id, allow_blank: true }, length: { maximum: 50 }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/, allow_blank: true }
  validates :project, presence: { unless: :quick_validation }

  def self.for_projects_and_keys keys_by_project
    conditions = ([ '(projects.api_id = ? AND test_keys.key IN (?))' ] * keys_by_project.length)
    values = keys_by_project.inject([]){ |memo,(k,v)| memo << k << v }
    where_args = values.unshift conditions.join(' OR ')
    joins(:project).where *where_args
  end

  def free?
    free
  end

  def to_s
    key
  end

  private

  def ensure_no_test_payloads
    raise ActiveRecord::DeleteRestrictionError, "Cannot delete record because of dependent test_keys" if test_payloads.any?
  end

  def set_value
    self.key ||= self.class.new_random_key project_id
  end

  # Generates a random test key that does not yet exist in the database.
  def self.new_random_key project_id
    tries = -1
    next while exists?(key: (key = generate_random_key(tries += 1)), project_id: project_id)
    key
  end

  def self.generate_random_key tries
    SecureRandom.random_alphanumeric 4 + (tries / 2).floor
  end
end

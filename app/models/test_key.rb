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
class TestKey < ActiveRecord::Base
  include QuickValidation
  include Tableling::Model
  KEY_REGEXP = /\A[a-z0-9]{12}\Z/

  before_create :set_value
  before_destroy :ensure_no_test_payloads

  belongs_to :user
  belongs_to :project
  has_one :test, class_name: 'ProjectTest', foreign_key: :key_id
  has_many :test_results, foreign_key: :key_id
  has_and_belongs_to_many :test_payloads

  strip_attributes
  validates :key, uniqueness: { scope: :project_id, if: :key }, format: { with: /\A[a-z0-9]{12}\Z/, allow_blank: true }
  validates :project, presence: { unless: :quick_validation }

  def self.for_projects_and_keys keys_by_project
    conditions = ([ '(projects.api_id = ? AND test_keys.key IN (?))' ] * keys_by_project.length)
    values = keys_by_project.inject([]){ |memo,(k,v)| memo << k << v }
    where_args = values.unshift conditions.join(' OR ')
    joins(:project).where *where_args
  end

  tableling do

    default_view do

      field :free, order: false
      field :project, order: false, includes: :project
      field :created_at, as: :createdAt

      field :value, order: false do
        value{ |o| o.key }
      end
      
      quick_search do |q,t|
        term = "%#{t.downcase}%"
        q.where('LOWER(test_keys.key) LIKE ?', term)
      end

      serialize_response do |res|
        if res[:legacy]
          LegacyTestKeysRepresenter.new OpenStruct.new(res)
        else
          TestKeysRepresenter.new OpenStruct.new(res)
        end
      end
    end
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
    next while exists?(key: (key = generate_random_key), project_id: project_id)
    key
  end

  def self.generate_random_key
    SecureRandom.random_alphanumeric 12
  end
end

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
class TestKey < ActiveRecord::Base
  include Tableling::Model

  before_create :set_value

  belongs_to :user
  belongs_to :project
  has_one :test_info, foreign_key: :key_id

  strip_attributes
  validates :user, presence: true
  validates :project, presence: true

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
        TestKeysRepresenter.new OpenStruct.new(res)
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

  def set_value
    self.key = self.class.new_random_key project_id
  end

  # Generates a random test key that does not yet exist in the database.
  def self.new_random_key project_id
    next while exists?(key: (key = generate_random_key), project_id: project_id)
    key
  end

  # Generates a random test key of 12 hexadecimal characters.
  def self.generate_random_key
    SecureRandom.hex 6 # result string is twice as long as n
  end
end

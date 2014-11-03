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
require_dependency 'random'

class Project < ActiveRecord::Base
  include Tableling::Model

  before_create :set_key

  has_many :tests, class_name: 'TestInfo'

  strip_attributes
  validates :name, presence: { name: :blankValue }, length: { maximum: 255, name: :valueTooLong }
  validates :description, length: { maximum: 1000, name: :valueTooLong }

  tableling do

    default_view do

      field :key, as: :id
      field :name
      field :description, order: false
      field :tests_count, as: :testsCount
      field :deprecated_tests_count, as: :deprecatedTestsCount
      field :created_at, as: :createdAt

      quick_search do |q,t|
        term = "%#{t.downcase}%"
        q.where 'LOWER(name) LIKE ? OR LOWER(key) LIKE ?', term, term
      end

      serialize_response do |res|
        res[:data].collect{ |p| p.to_builder.attributes! }
      end
    end
  end

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id key
      json.name name
      json.description description if description.present?
      json.testsCount tests_count
      json.deprecatedTestsCount deprecated_tests_count
      json.createdAt created_at.iso8601(3)
    end
  end

  def to_json options = {}
    to_builder(options).attributes!
  end

  private

  def self.generate_new_key
    next while exists?(key: key = generate_key)
    key
  end

  def self.generate_key
    SecureRandom.random_alphanumeric 12
  end

  def set_key
    self.key = self.class.generate_new_key
  end
end

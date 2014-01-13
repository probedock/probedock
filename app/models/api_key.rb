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
class ApiKey < ActiveRecord::Base
  include Tableling::Model

  before_create :set_identifier
  before_create :set_shared_secret

  belongs_to :user

  scope :authenticated, ->(id,secret) { where('api_keys.active = ? AND api_keys.identifier = ? AND api_keys.shared_secret = ? AND users.active = ?', true, id, secret, true).joins(:user).includes(:user) }

  # no need to validate identifier/shared_secret as they are generated
  validates :user, presence: true
  validates :active, inclusion: { in: [ true, false ], name: :invalidValue }

  def self.create_for_user user
    ApiKey.new.tap do |k|
      k.user = user
    end.tap{ |k| k.save! }
  end

  def self.find_by_identifier id
    where identifier: id
  end

  tableling do

    default_view do

      field :identifier, as: :id
      field :active, order: false
      field :usage_count, as: :usageCount
      field :last_used_at, as: :lastUsedAt
      field :created_at, as: :createdAt

      quick_search do |q,t|
        term = "%#{t.downcase}%"
        q.where('LOWER(api_keys.identifier) LIKE ?', term)
      end

      serialize_response do |res|
        ApiKeysRepresenter.new OpenStruct.new(res)
      end
    end
  end

  def to_param options = {}
    identifier
  end

  private

  def self.new_identifier
    next while exists?(identifier: id = generate_identifier)
    id
  end

  def self.generate_identifier
    SecureRandom.hex 10
  end

  def self.generate_shared_secret
    SecureRandom.hex 25
  end

  def set_identifier
    self.identifier = self.class.new_identifier
  end

  def set_shared_secret
    self.shared_secret = self.class.generate_shared_secret
  end
end

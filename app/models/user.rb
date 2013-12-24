# Copyright (c) 2012-2013 Lotaris SA
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
require 'digest/sha2'

class User < ActiveRecord::Base
  include Metric
  include Tableling::Model

  attr_accessor :cached_groups

  after_create :create_api_key
  after_create :clear_app_cache
  after_destroy :clear_app_cache

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable, :validatable
  if ROXCenter::AUTHENTICATION_MODULE == 'ldap'
    devise :ldap_authenticatable, :rememberable, :trackable
  else
    devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable
  end

  # Role-based authorization
  include RoleModel

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  roles :admin, :technical

  has_many :api_keys, dependent: :destroy
  has_many :test_keys, dependent: :destroy
  has_many :free_test_keys, -> { where free: true }, class_name: "TestKey"
  has_many :test_infos, foreign_key: :author_id, dependent: :restrict_with_exception
  has_many :runs, class_name: "TestRun", foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_results, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_counters, dependent: :restrict_with_exception
  belongs_to :last_run, class_name: "TestRun"

  strip_attributes
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  tableling do

    default_view do

      field :id
      field :name
      field :email
      field :created_at

      quick_search do |query,original_term|
        term = "%#{original_term.downcase}%"
        query.where('LOWER(users.name) LIKE ?', term)
      end
    end
  end

  def active_for_authentication?
    !!active
  end

  def deletable?
    test_infos.empty? and test_results.empty? and test_counters.empty?
  end

  def to_s
    name
  end

  def to_param options = {}
    name
  end

  def to_client_hash options = {}
    { id: id, name: name }.tap do |h|

      h[:email] = email if email.present?
      h[:technical] = true if technical? 

      if options[:type] == :info
        h[:active] = active
        h[:deletable] = deletable?
        h[:created_at] = created_at.to_i * 1000
      end
    end
  end

  # Generates a random remember token that does not yet exist in the database.
  def self.remember_token
    while exists?(remember_token: (token = generate_remember_token)); end
    token
  end

  # Generates a random remember token of 16 hexadecimal characters.
  def self.generate_remember_token
    SecureRandom.hex 8 # result string is twice as long as n
  end

  private

  def clear_app_cache
    JsonCache.clear :app_status
  end

  def create_api_key
    ApiKey.create_for_user self
  end
end

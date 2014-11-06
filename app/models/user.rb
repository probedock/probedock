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
require 'digest/sha2'

class User < ActiveRecord::Base
  include Tableling::Model

  has_secure_password

  before_create :create_settings
  after_create{ Rails.application.events.fire 'user:created' }
  after_destroy{ Rails.application.events.fire 'user:destroyed' }

  # Role-based authorization
  include RoleModel

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  roles :admin, :technical

  has_many :test_keys, dependent: :destroy
  has_many :free_test_keys, -> { select('test_keys.*').joins('LEFT OUTER JOIN test_keys_payloads ON (test_keys.id = test_keys_payloads.test_key_id)').where(free: true).where('test_keys_payloads.test_payload_id IS NULL').group('test_keys.id') }, class_name: "TestKey"
  has_many :test_infos, foreign_key: :author_id, dependent: :restrict_with_exception
  has_many :test_payloads, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_results, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_counters, dependent: :restrict_with_exception
  has_many :test_payloads, dependent: :restrict_with_exception
  belongs_to :last_test_payload, class_name: "TestPayload"
  belongs_to :settings, class_name: "Settings::User", dependent: :destroy
  belongs_to :email, class_name: "UserEmail"

  strip_attributes
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  tableling do

    default_view do

      field :name
      field :created_at, as: :createdAt

      field :email do
        order{ |q,d| q.joins(:email).where("user_emails.email #{d}") }
        value{ |o| o.email.email }
      end

      quick_search do |query,original_term|
        term = "%#{original_term.downcase}%"
        query.where('LOWER(users.name) LIKE ?', term)
      end

      serialize_response do |res|
        UsersRepresenter.new OpenStruct.new(res)
      end
    end
  end

  def generate_auth_token
    JSON::JWT.new({
      iss: email.email,
      exp: 1.week.from_now,
      nbf: Time.now
    }).sign(Rails.application.secrets.secret_key_base, 'HS512').to_s
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

  def client_cache_key
    Digest::SHA1.hexdigest "#{created_at.to_r}-#{id}"
  end

  def to_client_hash options = {}
    { id: id, name: name }.tap do |h|

      h[:email] = email if email.present?
      h[:technical] = true if technical? 

      if options[:type] == :info
        h[:active] = active
        h[:deletable] = deletable?
        h[:created_at] = created_at.to_ms
      end
    end
  end

  private

  def create_settings
    self.settings = Settings::User.new.tap(&:save!)
  end
end

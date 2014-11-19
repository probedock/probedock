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
class User < ActiveRecord::Base
  include JsonResource
  include IdentifiableResource
  include Tableling::Model

  before_create{ set_identifier :api_id }

  has_secure_password

  after_create :create_settings
  after_create{ Rails.application.events.fire 'user:created' }
  after_destroy{ Rails.application.events.fire 'user:destroyed' }

  # Role-based authorization
  include RoleModel

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  roles :admin

  has_many :test_keys, dependent: :destroy
  has_many :free_test_keys, -> { select('test_keys.*').joins('LEFT OUTER JOIN test_keys_payloads ON (test_keys.id = test_keys_payloads.test_key_id)').where(free: true).where('test_keys_payloads.test_payload_id IS NULL').group('test_keys.id') }, class_name: "TestKey"
  # TODO: replace with contributions
  #has_many :test_infos, foreign_key: :author_id, dependent: :restrict_with_exception
  has_many :test_payloads, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_results, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_reports, foreign_key: :runner_id, dependent: :restrict_with_exception
  belongs_to :last_test_payload, class_name: "TestPayload"
  has_one :settings, class_name: "Settings::User", dependent: :destroy
  belongs_to :email # TODO: make email required

  strip_attributes except: :password_digest
  validates :name, presence: true, uniqueness: true
  validates :email, presence: true
  validates :email_id, uniqueness: true

  tableling do

    default_view do

      field :name
      field :created_at, as: :createdAt

      field :email, includes: :email do
        order{ |q,d| q.joins(:email).where("emails.email #{d}") }
        value{ |o| o.email.email }
      end

      quick_search do |query,original_term|
        term = "%#{original_term.downcase}%"
        query.where 'LOWER(users.name) LIKE ?', term
      end

      serialize_response do |res|
        res[:data].collect{ |p| p.to_builder.attributes! }
      end
    end
  end

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      # TODO: hide active, email and name if not logged in
      json.email email.email if email.present?
      # TODO: cache email MD5
      json.emailMd5 Digest::MD5.hexdigest(email.email) if email.present?
      json.name name

      unless options[:link]
        json.active active
        json.createdAt created_at.iso8601(3)
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

  private

  def create_settings
    self.settings = Settings::User.new(user: self).tap(&:save!)
  end
end

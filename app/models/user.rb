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
class User < ActiveRecord::Base
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id }

  has_secure_password

  after_create :create_settings

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  include RoleModel
  roles :admin

  has_many :test_keys, dependent: :destroy
  has_many :free_test_keys, -> { select('test_keys.*').joins('LEFT OUTER JOIN test_keys_payloads ON (test_keys.id = test_keys_payloads.test_key_id)').where(free: true).where('test_keys_payloads.test_payload_id IS NULL').group('test_keys.id') }, class_name: 'TestKey'
  # TODO: replace with contributions
  #has_many :test_infos, foreign_key: :author_id, dependent: :restrict_with_exception
  has_many :test_payloads, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_results, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :test_reports, foreign_key: :runner_id, dependent: :restrict_with_exception
  has_many :memberships
  belongs_to :last_test_payload, class_name: 'TestPayload'
  has_one :settings, class_name: 'Settings::User', dependent: :destroy
  belongs_to :primary_email, class_name: 'Email'
  # TODO: purge emails if unused
  has_and_belongs_to_many :emails

  strip_attributes except: :password_digest
  validates :name, presence: true, uniqueness: true, length: { maximum: 25 }
  validates :primary_email, presence: true

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      # TODO: hide active, email and name if not logged in
      json.email primary_email.address
      # TODO: cache email MD5
      json.emailMd5 Digest::MD5.hexdigest(primary_email.address)
      json.name name

      unless options[:link]
        json.active active
        json.roles roles.collect(&:to_s)
        json.createdAt created_at.iso8601(3)
      end
    end
  end

  def generate_auth_token
    JSON::JWT.new({
      iss: primary_email.address,
      exp: 1.week.from_now,
      nbf: Time.now
    }).sign(Rails.application.secrets.secret_key_base, 'HS512').to_s
  end

  def primary_email= email
    super email
    self.emails << email if email.present? && !emails.include?(email)
  end

  def member_of? organization
    memberships.any?{ |m| m.organization == organization }
  end

  def membership_in organization
    memberships.find{ |m| m.organization == organization }
  end

  private

  def create_settings
    self.settings = Settings::User.new(user: self).tap(&:save!)
  end
end

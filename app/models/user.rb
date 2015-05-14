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
  # TODO: make sure "active" is used
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id }

  has_secure_password

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
  has_many :organizations, through: :memberships
  belongs_to :primary_email, class_name: 'Email', autosave: true
  # TODO: purge emails if unused
  has_many :emails

  strip_attributes except: :password_digest
  validates :name, presence: true, uniqueness: true, length: { maximum: 25 }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/i, allow_blank: true }
  # TODO: validate min password length
  validates :primary_email, presence: true
  validate :primary_email_must_be_among_emails

  def generate_auth_token
    JSON::JWT.new({
      iss: api_id,
      exp: 1.year.from_now,
      nbf: Time.now
    }).sign(Rails.application.secrets.jwt_secret, 'HS512').to_s
  end

  def primary_email= email
    self.emails << email if primary_email.blank? && emails.blank?
    super email
  end

  def member_of? organization
    memberships.any?{ |m| m.organization == organization }
  end

  def membership_in organization
    memberships.find{ |m| m.organization == organization }
  end

  private

  def primary_email_must_be_among_emails
    errors.add :primary_email, :must_be_among_emails unless emails.include? primary_email
  end
end

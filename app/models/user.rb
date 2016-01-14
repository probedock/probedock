# Copyright (c) 2015 ProbeDock
# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ProbeDock.
#
# ProbeDock is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ProbeDock is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ProbeDock.  If not, see <http://www.gnu.org/licenses/>.
class User < ActiveRecord::Base
  # TODO: make sure "active" is used
  include IdentifiableResource

  # TODO: remove this and the associated rake task once no longer needed
  attr_accessor :technical_validation_disabled

  before_create :set_identifier
  after_save :complete_registration

  has_secure_password validations: false

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
  has_many :memberships, dependent: :destroy # TODO: cascade in database
  has_many :organizations, through: :memberships
  belongs_to :primary_email, class_name: 'Email', autosave: true
  has_one :registration, class_name: 'UserRegistration'
  # TODO: purge emails if unused
  has_many :emails
  has_many :test_contributions

  strip_attributes except: :password_digest
  # TODO: validate min name length
  validates :name, presence: true, uniqueness: true, length: { maximum: 25, allow_blank: true }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\Z/i, allow_blank: true }
  # TODO: validate min password length
  validates :primary_email, presence: { unless: :technical }, absence: { if: :technical }
  validates :primary_email_id, uniqueness: { if: :primary_email_id }
  validates :password, length: { if: ->(u){ u.human? && u.active? }, maximum: 512 }, confirmation: { if: ->(u){ u.human? && u.active? }, allow_blank: true }
  validate :primary_email_must_be_among_emails
  validate :technical_must_not_change

  validate do |record|
    record.errors.add :password, :blank if human? && active? && record.password_digest.blank?
    record.errors.add :password, :present if record.password_digest.present? && (technical? || !active?)
  end

  def generate_auth_token
    JSON::JWT.new({
      iss: api_id,
      exp: 1.year.from_now.to_i,
      nbf: Time.now
    }).sign(Rails.application.secrets.jwt_secret, 'HS512').to_s
  end

  def primary_email= email
    self.emails << email if primary_email.blank? && emails.blank? && email.present?
    super email
  end

  def member_of? organization
    memberships.any?{ |m| m.organization == organization }
  end

  def membership_in organization
    memberships.find{ |m| m.organization == organization }
  end

  def technical?
    !!technical
  end

  def human?
    !technical
  end

  def active?
    active
  end

  private

  def primary_email_must_be_among_emails
    errors.add :primary_email, :must_be_among_emails unless primary_email.blank? || emails.include?(primary_email)
  end

  def technical_must_not_change
    errors.add :technical, :must_not_change if technical_changed? && persisted? && !technical_validation_disabled
  end

  def complete_registration
    if active_changed? && active? && registration.present? && !registration.completed?
      registration.update_attribute :completed, true
      self.primary_email.update_attribute :active, true
      registration.organization.update_attribute :active, true if registration.organization.present?
    end
  end
end

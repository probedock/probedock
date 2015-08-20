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
class Membership < ActiveRecord::Base
  include IdentifiableResource

  before_create{ set_identifier :api_id, size: 12 }
  before_create :set_otp
  before_save :set_accepted_at
  before_save :remove_otp
  after_save :add_organization_email_to_user

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  include RoleModel
  roles :admin

  belongs_to :user
  belongs_to :organization, counter_cache: true
  belongs_to :organization_email, class_name: 'Email'

  validates :organization, presence: true
  validates :organization_email, presence: { if: ->(m){ m.user_id && m.user.human? } }, absence: { if: ->(m){ m.user_id && m.user.technical? } }
  validates :user_id, uniqueness: { scope: :organization_id, if: :user_id }
  validate :organization_email_must_be_free_or_owned_by_user
  validate :technical_user_must_not_be_in_another_organization

  private

  def organization_email_must_be_free_or_owned_by_user
    if organization_email.present? && user.present? && !user.emails.include?(organization_email) && organization_email.user.present?
      errors.add :organization_email, :must_be_owned_by_user
    end
  end

  def technical_user_must_not_be_in_another_organization
    if organization.present? && user.present? && user.technical? && user.memberships.reject{ |m| m.organization_id == organization.id }.present?
      errors.add :user_id, :must_not_be_technical_user_from_another_organization
    end
  end

  def add_organization_email_to_user
    if user.present? && organization_email.present? && organization_email.user.blank?
      organization_email.user = user
      organization_email.active = true
      organization_email.save!
    end
  end

  def set_accepted_at
    self.accepted_at ||= Time.now if user.present? && user.human?
  end

  def set_otp
    unless user.present?
      # TODO: use set_identifier
      self.otp = SecureRandom.base64 150
      self.expires_at = 1.week.from_now
    end
  end

  def remove_otp
    if user.present?
      self.otp = nil
      self.expires_at = nil
    end
  end
end

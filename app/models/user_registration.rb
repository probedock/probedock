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
class UserRegistration < ActiveRecord::Base
  include IdentifiableResource

  before_create :set_identifier
  before_create :set_otp
  after_create :create_membership
  before_save :remove_otp_and_set_completed_at_if_completed

  belongs_to :user, autosave: true
  belongs_to :organization, autosave: true

  strip_attributes
  validates :user, presence: true
  validates :user_id, uniqueness: true

  def completed?
    completed
  end

  private

  def set_otp
    self.otp = SecureRandom.base64 100
    self.expires_at = 1.week.from_now
  end

  def remove_otp_and_set_completed_at_if_completed
    if completed?
      self.otp = nil
      self.expires_at = nil
    end
  end

  def create_membership
    if organization.present?
      membership = Membership.new
      membership.user = user
      membership.organization = organization
      membership.organization_email = user.primary_email
      membership.roles = %i(admin)
      membership.accepted_at = created_at
      membership.save!
    end
  end
end

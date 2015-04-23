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
class Membership < ActiveRecord::Base
  include JsonResource
  include IdentifiableResource

  before_create{ set_identifier :api_id, size: 12 }
  before_save :set_accepted_at

  # List of roles. DO NOT change the order of the roles, as they
  # are stored in a bitmask. Only append new roles to the list.
  include RoleModel
  roles :admin

  belongs_to :organization, counter_cache: true
  belongs_to :organization_email, class_name: 'Email'
  belongs_to :user

  validates :organization, presence: true
  validates :organization_email, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, if: :user_id }

  def to_builder options = {}
    Jbuilder.new do |json|
      json.id api_id
      json.organizationId organization.api_id
      json.organization organization.to_builder.attributes! if options[:with_organization]
      # TODO: only show organization email for org admins
      json.organizationEmail organization_email.address
      json.roles roles.collect(&:to_s)
      json.createdAt created_at.iso8601(3)
      json.acceptedAt accepted_at.iso8601(3) if accepted_at.present?
      json.updatedAt updated_at.iso8601(3)

      if user.present?
        json.userId user.api_id
        json.user user.to_builder.attributes! if options[:with_user]
      end
    end
  end

  private

  def set_accepted_at
    self.accepted_at ||= Time.now if user.present?
  end
end

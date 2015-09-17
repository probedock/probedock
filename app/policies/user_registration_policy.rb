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
class UserRegistrationPolicy < ApplicationPolicy
  def index?
    admin? || registration_otp?
  end

  def create?
    enabled?
  end

  private

  def registration_otp?
    otp_record? UserRegistration
  end

  def enabled?
    Settings.app.user_registration_enabled
  end

  public

  class Scope < Scope
    def resolve
      if registration_otp?
        scope.where id: otp_record.id
      else
        scope
      end
    end

    private

    def registration_otp?
      otp_record? UserRegistration
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.id record.api_id
        json.user serialize(record.user, options[:user_options])
        json.organization serialize(record.organization, options[:organization_options]) if record.organization.present?
        json.completed record.completed
        json.expiresAt record.expires_at.iso8601(3) if record.expires_at.present?
        json.completedAt record.completed_at.iso8601(3) if record.completed_at.present?
        json.createdAt record.created_at.iso8601(3)
      end
    end
  end
end

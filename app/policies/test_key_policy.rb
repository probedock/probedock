# Copyright (c) 2015 Probe Dock
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
class TestKeyPolicy < ApplicationPolicy
  def create?
    user.is?(:admin) || user.member_of?(record.project.try(:organization))
  end

  def index?
    user.is?(:admin) || (organization && user.member_of?(organization))
  end

  def release?
    user
  end

  class Scope < Scope
    def resolve
      if user.is? :admin
        scope
      else
        scope.where projects: { organization_id: organization.id }
      end
    end
  end

  class Serializer < Serializer
    def to_builder options = {}
      Jbuilder.new do |json|
        json.key record.key
        json.free record.free
        json.projectId record.project.api_id
        json.userId record.user.api_id if record.user.present?
        json.createdAt record.created_at.iso8601(3)
        json.updatedAt record.updated_at.iso8601(3)
      end
    end
  end
end

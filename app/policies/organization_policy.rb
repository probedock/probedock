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
class OrganizationPolicy < ApplicationPolicy
  def create?
    user.is? :admin
  end

  def index?
    true
  end

  def show?
    organization.public? || user.try(:is?, :admin) || user.try(:member_of?, organization)
  end

  def data?
    organization.public? || user.try(:is?, :admin) || user.try(:member_of?, organization)
  end

  def update?
    user.is?(:admin) || user.membership_in(organization).try(:is?, :admin)
  end

  class Scope < Scope
    def resolve
      if user.try :is?, :admin
        scope
      else
        scope.where public_access: true
      end
    end
  end
end

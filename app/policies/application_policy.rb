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
class ApplicationPolicy
  attr_reader :user, :organization, :otp_record, :params, :record

  def initialize user, record
    @user = user
    @record = record

    if user.kind_of? UserContext
      @user = user.user
      @organization = user.organization
      @otp_record = user.otp_record
      @params = user.params
    end
  end

  def default?
    false
  end

  def collection_default?
    false
  end

  def index?
    collection_default?
  end

  def show?
    default?
  end

  def create?
    collection_default?
  end

  def update?
    default?
  end

  def destroy?
    default?
  end

  def scope
    Pundit.policy_scope! user, record.class
  end

  class Scope
    attr_reader :user, :organization, :otp_record, :params, :scope

    def initialize user, scope
      @user = user
      @scope = scope

      if user.kind_of? UserContext
        @user = user.user
        @organization = user.organization
        @otp_record = user.otp_record
        @params = user.params
      end
    end

    def resolve
      scope
    end
  end
end

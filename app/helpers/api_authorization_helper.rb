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
module ApiAuthorizationHelper
  def authorize! record, query
    query = "#{query}?" unless query.to_s.last == '?'
    Pundit.authorize pundit_user, record, query
  end

  def policy record
    Pundit.policy! pundit_user, record
  end

  def policy_scope scope
    Pundit.policy_scope! pundit_user, scope
  end

  def pundit_user

    user = current_user
    org = respond_to?(:current_organization) ? current_organization : nil

    UserContext.new user, org
  end
end

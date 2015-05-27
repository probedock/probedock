# Copyright (c) 2015 ProbeDock
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

  def policy subject, user = nil
    Pundit.policy! user || pundit_user, subject
  end

  def policy_scope subject
    Pundit.policy_scope! pundit_user, subject
  end

  def policy_serializer subject, user = nil
    policy(subject, user).serializer
  end

  def pundit_user

    user = current_user
    org = respond_to?(:current_organization) ? current_organization : nil
    otp_record = respond_to?(:current_otp_record) ? current_otp_record : nil

    UserContext.new user, org, otp_record, params
  end
end

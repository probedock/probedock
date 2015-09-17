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
module PolicyHelpers
  extend ActiveSupport::Concern

  included do
    attr_reader :user, :organization, :otp_record, :params
  end

  private

  def expand_user_context!
    if @user.kind_of? UserContext
      @user_context = @user
      @user = @user_context.user
      @organization = @user_context.organization
      @otp_record = @user_context.otp_record
      @params = @user_context.params
    end
  end

  def app?
    user == :app
  end

  def admin?
    role? :admin
  end

  def human?
    user.kind_of(User) && user.try(:human?)
  end

  def technical?
    user.kind_of(User) && user.try(:technical?)
  end

  def otp_record? type = nil
    otp_record.present? && (type.nil? || otp_record.kind_of?(type))
  end

  def role? *roles
    user.kind_of?(User) && user.has_all_roles?(*roles)
  end
end

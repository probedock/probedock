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
module ProbeDock
  class AccessTokensApi < Grape::API

    namespace :tokens do

      before do
        authenticate!
      end

      post do

        user = if params[:userId].present?
          User.where(api_id: params[:userId].to_s).first!
        else
          current_user
        end

        token = AccessToken.new user

        authorize! token, :create

        { token: token.token, userId: token.user.api_id }
      end
    end
  end
end

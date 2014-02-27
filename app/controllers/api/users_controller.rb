# Copyright (c) 2012-2014 Lotaris SA
#
# This file is part of ROX Center.
#
# ROX Center is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ROX Center is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
class Api::UsersController < Api::ApiController
  before_filter :check_maintenance, only: [ :update, :destroy ]

  load_resource
  skip_load_resource except: [ :show, :update, :destroy ]
  authorize_resource only: [ :update, :destroy ]

  def index
    render_api User.tableling.process(params)
  end

  def show
    render_api UserRepresenter.new(@user, detailed: true)
  end

  def update

    @user.active = !!params[:active].to_s.match(/\A(1|yes|t|true)\Z/i) if params.key? :active

    if @user.save
      render json: UserRepresenter.new(@user, detailed: true)
    else
      render_api_model_errors @user
    end
  end

  def destroy
    begin
      @user.destroy
      flash[:success] = t('users.destroy.success', user: @user.name)
      head :no_content
    rescue ActiveRecord::DeleteRestrictionError
      return render text: t('users.destroy.restricted'), status: 409
    end
  end
end

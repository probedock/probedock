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
class AccountApiKeysController < Api::ApiController
  skip_before_filter :authenticate_api_user!
  before_filter :authenticate_user!
  before_filter :check_maintenance, only: [ :create, :update, :destroy ]

  authorize_resource class: 'ApiKey', only: [ :index ]
  load_and_authorize_resource class: 'ApiKey', find_by: :identifier, except: [ :index ]

  def index
    render_api ApiKey.tableling.process(params.merge base: ApiKey.where(user_id: current_api_user))
  end

  def create
    render_api ApiKeyRepresenter.new(@account_api_key.tap{ |k| k.save! })
  end

  def show
    render_api ApiKeyRepresenter.new(@account_api_key, detailed: true)
  end

  def update
    if @account_api_key.update_attributes params.require(:account_api_key).permit(:active)
      render_api ApiKeyRepresenter.new(@account_api_key)
    else
      render_api_model_errors @account_api_key
    end
  end

  def destroy
    @account_api_key.destroy
    head :no_content
  end
end

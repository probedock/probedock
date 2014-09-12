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
class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_maintenance, only: [ :destroy ]
  before_filter(only: [ :create, :update ]) do
    if @maintenance
      if request.xhr?
        render_maintenance
      else
        redirect_to action: :index
      end
    end
  end

  load_resource find_by: :name, only: [ :new, :show, :edit, :update, :destroy, :tests_page ]
  authorize_resource only: [ :new, :create, :edit, :update, :destroy ]

  def index
    window_title << User.model_name.human.pluralize.titleize
  end

  def create

    @user = User.new user_params
    @user.active = !!params[:user].try(:delete, :active)

    if @user.save
      redirect_to @user
    else
      render action: :new
    end
  end

  def show
    window_title << User.model_name.human.pluralize.titleize << @user.name

    @user_info_config = {
      user: UserRepresenter.new(@user, detailed: true).serializable_hash,
      can: { manage: can?(:manage, User) }
    }

    @tests_table_config = {
      halUrlTemplate: { 'authors[]' => [ @user.name ] },
      search: TestSearch.config(params, except: [ :authors, :current ])
    }
  end

  def edit
    window_title << User.model_name.human.pluralize.titleize << @user.name
  end
  
  def update

    p = user_params
    @user.update_attribute :active, !!p.delete(:active).to_s.match(/\A(1|yes|t|true)\Z/i) if p.try :key?, :active

    if p[:password].blank?
      p.delete :password
    end

    if @user.update_attributes p
      return render json: @user.to_client_hash if request.xhr?
      flash[:success] = t('users.edit.updateNotice', user: @user.name)
      redirect_to @user
    else
      render action: :edit
    end
  end

  def destroy
    begin
      @user.destroy
      flash[:success] = t('users.destroy.success', user: @user.name)
      head :no_content
    rescue ActiveRecord::DeleteRestrictionError
      return render plain: t('users.destroy.restricted'), status: 409
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :active, :password, :password_confirmation, :remember_me)
  end
end

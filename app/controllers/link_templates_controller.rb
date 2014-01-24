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
class LinkTemplatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter{ authorize! :manage, :settings }
  load_resource only: [ :update, :destroy ]

  def create
    create_and_render_record LinkTemplate
  end

  def update
    update_and_render_record @link_template
  end

  def destroy
    destroy_and_render_record @link_template
  end

  private

  def link_params
    params[:link_template].permit(:name, :contents)
  end

  def record_params_for_save *args
    super(*args).permit(:name, :contents)
  end
end

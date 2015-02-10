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
class HomeController < ApplicationController

  def template

    # only accept html templates
    return render_template_not_found unless params[:format] == 'html'

    # only accept alphanumeric characters, hyphens and underscores, separated by slashes
    return render_template_not_found unless params[:name].to_s.match /\A[a-z0-9\-\_]+(\.[a-z0-9\-\_]+)*\Z/i

    begin
      render template: "templates/#{params[:name]}", layout: false
    rescue ActionView::MissingTemplate
      render_template_not_found
    end
  end

  private

  def render_template_not_found
    render text: 'Template not found', status: :not_found
  end
end

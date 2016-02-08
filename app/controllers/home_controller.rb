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
class HomeController < ApplicationController
  caches_page :index
  append_view_path Rails.root.join('client')

  def index
    render template: 'index'
  end

  def template

    # only accept html templates
    return render_template_not_found unless params[:format] == 'html'

    # only accept alphanumeric characters, hyphens and underscores, separated by slashes
    return render_template_not_found unless params[:path].to_s.match /\A[a-z0-9\-\_]+(\/[a-z0-9\-\_]+(?:\.[a-z0-9\-\_]+)*)*(?:\.template)?\Z/i

    begin
      render_template params[:path]
    rescue ActionView::MissingTemplate
      render_template_not_found
    end
  end

  private

  def render_template path
    if path.match /\.template$/
      render template: path, layout: false
    else
      # TODO: remove this once all templates have been migrated
      render template: "templates/#{path}", layout: false
    end
  end

  def render_template_not_found
    render text: 'Template not found', status: :not_found
  end
end

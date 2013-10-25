# Copyright (c) 2012-2013 Lotaris SA
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

module Renderer

  def self.render options = {}

    assigns = options.delete(:assigns) || {}
    view = view_class.new ActionController::Base.view_paths, assigns

    view.extend ApplicationHelper
    view.extend HumanHelper
    view.extend ReportHelper

    view.render options
  end

  def self.view_class
    @view_class ||= Class.new ActionView::Base do
      include Rails.application.routes.url_helpers

      def default_url_options options = {}
        { locale: I18n.locale }
      end
    end
  end
end

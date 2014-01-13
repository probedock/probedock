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
module ApplicationHelper

  def body_data
    # TODO: spec ApplicationHelper#body_data
    data = {}
    data[:config] = @page_config.to_json if @page_config
    data[:status] = @status_data.to_json if @status_data
    data.present? ? data : nil
  end

  def human_window_title
    window_title.join t('common.title_separator')
  end

  def meta_session
    Hash.new.tap do |h|
      h[:admin] = true if current_user.try(:admin?)
    end
  end

  def meta_maintenance
    {
      since: @maintenance[:since].to_i * 1000
    }
  end
end

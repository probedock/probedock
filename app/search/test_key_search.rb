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
class TestKeySearch

  def self.options params, options = {}

    q = TestKey
    return { base: q } if params.blank?

    if params[:free].to_s.match(/\A(1|y|yes|t|true)\Z/i)
      q = q.where free: true
    elsif params[:free].to_s.match(/\A(0|n|no|f|false)\Z/i)
      q = q.where free: false
    end

    if (projectApiId = params[:projectApiId].to_s).present?
      q = q.joins(:project).where 'projects.api_id = ?', projectApiId
    end

    { base: q }
  end
end

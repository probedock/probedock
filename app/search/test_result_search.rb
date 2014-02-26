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
class TestResultSearch

  def self.options params, options = {}

    q = TestResult

    if options[:test]
      q = q.where('test_results.test_info_id = ?', options[:test].id)
    else
      raise "Results must be filtered with the :test option"
    end

    return params.merge(base: q) if params.blank?

    version = params[:version].to_s.strip
    q = q.joins(:project_version).where('project_versions.name = ?', version) if version.present?

    params.merge base: q
  end
end

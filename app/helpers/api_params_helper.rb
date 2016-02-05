# Copyright (c) 2015 ProbeDock
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

# Utility methods to parse API params, available to all API classes mounted in `ProbeDock::API`.
module ApiParamsHelper

  # Returns true if the specified query parameter is present and has a true-ish value.
  # The following values are considered true: 1, y, yes, t, true (case-insensitive).
  def true_flag? name
    !!params[name].to_s.match(/\A(?:1|y|yes|t|true)\Z/i)
  end

  # Returns true if the specified query parameter is present and has a false-ish value.
  # The following values are considered false: 0, n, no, f, false (case-insensitive).
  #
  # Note that this method returns false if the query parameter is not set.
  # It is meant to detect an explicit false flag.
  def false_flag? name
    !!params[name].to_s.match(/\A(?:0|n|no|f|false)\Z/i)
  end

  # Returns true if the specified query parameter is present and is an array.
  def array_param? name
    params[name].present? && params[name].kind_of?(Array)
  end
end

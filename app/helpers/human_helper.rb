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

module HumanHelper
  DURATIONS = [
    { name: :d, value: 86400000 },
    { name: :h, value: 3600000 },
    { name: :m, value: 60000 },
    { name: :s, value: 1000 },
    { name: :ms, value: 1 }
  ]

  def human_duration ms, options = {}
    return '0' if ms <= 0
    ms = ms - (ms % 1000) if options[:format] == :short and ms > 1000
    DURATIONS.inject([]) do |memo,d|
      value = (ms / d[:value].to_f).floor
      if value >= 1
        ms = ms - value * d[:value]
        memo << "#{value}#{d[:name]}"
      end
      memo
    end.join ' '
  end
end

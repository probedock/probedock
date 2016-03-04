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
module NamedRecordsSpecHelper
  def add_named_record name, record
    @named_records ||= {}
    raise "A named record already exists for name #{name.inspect}" if @named_records[name]
    @named_records[name] = record
  end

  def named_record name
    record = @named_records.try :[], name
    raise "Unknown named record #{name.inspect}" unless record
    record
  end

  def named_record_exists name
    !@named_records.try(:[], name).nil?
  end
end

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
RSpec::Matchers.define :have_db_columns do |*expected|
  match do |actual|
    @actual = actual.kind_of?(ActiveRecord::Base) ? actual.class : actual
    columns = @actual.columns
    @actual_columns = columns.collect(&:name).collect(&:to_s).sort
    @expected_columns = expected.collect(&:to_s).sort
    @actual_columns == @expected_columns
  end

  failure_message do
    "#{@actual} does not have the expected database columns".tap do |msg|
      msg << "\n  expected: #{describe_columns(@expected_columns)}"
      msg << "\n       got: #{describe_columns(@actual_columns)}"

      missing_columns = @expected_columns - @actual_columns
      msg << "\n   missing: #{describe_columns(missing_columns)}" if missing_columns.any?

      extra_columns = @actual_columns - @expected_columns
      msg << "\n     extra: #{describe_columns(extra_columns)}" if extra_columns.any?
    end
  end

  def describe_columns columns
    columns.collect{ |c| ":#{c}" }.join ', '
  end
end

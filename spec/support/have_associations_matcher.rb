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
RSpec::Matchers.define :have_associations do |*expected|
  match do |actual|
    @actual = actual.kind_of?(ActiveRecord::Base) ? actual.class : actual
    associations = @actual.reflect_on_all_associations
    @actual_associations = associations.collect(&:name).collect(&:to_s).sort
    @expected_associations = expected.collect(&:to_s).sort
    @actual_associations == @expected_associations
  end

  failure_message do
    "#{@actual} does not have the expected associations".tap do |msg|
      msg << "\n  expected: #{describe_associations(@expected_associations)}"
      msg << "\n       got: #{describe_associations(@actual_associations)}"

      missing_associations = @expected_associations - @actual_associations
      msg << "\n   missing: #{describe_associations(missing_associations)}" if missing_associations.any?

      extra_associations = @actual_associations - @expected_associations
      msg << "\n     extra: #{describe_associations(extra_associations)}" if extra_associations.any?
    end
  end

  def describe_associations associations
    associations.collect{ |c| ":#{c}" }.join ', '
  end
end

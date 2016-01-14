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
RSpec::Matchers.define :have_validations_on do |*expected|
  match do |actual|
    @actual = actual.kind_of?(ActiveRecord::Base) ? actual.class : actual
    validators = @actual.validators
    @actual_attributes = validators.collect(&:attributes).flatten.uniq.collect(&:to_s).sort
    @expected_attributes = expected.collect(&:to_s).sort
    @actual_attributes == @expected_attributes
  end

  failure_message do
    "#{@actual} does not validate the expected attributes".tap do |msg|
      msg << "\n  expected: #{describe_attributes(@expected_attributes)}"
      msg << "\n       got: #{describe_attributes(@actual_attributes)}"

      missing_attributes = @expected_attributes - @actual_attributes
      msg << "\n   missing: #{describe_attributes(missing_attributes)}" if missing_attributes.any?

      extra_attributes = @actual_attributes - @expected_attributes
      msg << "\n     extra: #{describe_attributes(extra_attributes)}" if extra_attributes.any?
    end
  end

  def describe_attributes attributes
    attributes.collect{ |c| ":#{c}" }.join ', '
  end
end

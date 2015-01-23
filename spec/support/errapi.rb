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
RSpec::Matchers.define :have_api_errors do |expected_errors|

  match do |actual|

    res = if actual.kind_of? Hash
      actual
    elsif actual.kind_of? String
      MultiJson.load actual
    else
      MultiJson.load actual.body
    end

    actual_errors = res['errors']
    @missing_errors = []
    @extra_errors = actual_errors

    expected_errors.each do |expected_error|
      error = actual_errors.find do |actual_error|
        expected_error.all? do |k,v|
          v.kind_of?(Regexp) ? !!v.match(actual_error[k.to_s]) : v == actual_error[k.to_s]
        end
      end

      if error
        actual_errors.delete error
      else
        @missing_errors << expected_error
      end
    end

    @missing_errors.empty? && @extra_errors.empty?
  end

  failure_message do |actual|
    Array.new.tap do |msg|
      msg << "expected API response to contain #{expected_errors.length} errors"
      msg << "the following expected errors were not found: #{@missing_errors}" if @missing_errors.any?
      msg << "the following extra errors were found: #{@extra_errors}" if @extra_errors.any?
    end.join '; '
  end
end

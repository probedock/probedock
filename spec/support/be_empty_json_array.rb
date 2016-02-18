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
RSpec::Matchers.define :be_empty_json_array do

  match do |actual|

    @res = if actual.kind_of? String
      MultiJson.load actual
    elsif actual.respond_to? :body
      MultiJson.load actual.body
    else
      raise "Unsupported assertion subject #{actual.inspect}"
    end

    @not_an_array = @res.nil? || !@res.is_a?(Array)
    @res.empty? unless @not_an_array
  end

  failure_message do |actual|
    return "JSON '#{@res}' is not an array" if @not_an_array
    "JSON '#{@res}' is not empty"
  end
end

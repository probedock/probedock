# Copyright (c) 2015 42 inside
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

RSpec::Matchers.define :have_properties do |expected|

  match do |actual|
    expected.stringify_keys.all?{ |k,v| actual[k] == v }
  end

  description do
    "have properties #{expected.inspect}"
  end
end

RSpec::Matchers.define :have_only_properties do |expected|

  match do |actual|
    actual.reject{ |k,v| %w(_links _embedded).include? k } == expected.stringify_keys
  end

  description do
    "have only properties #{expected.inspect}"
  end
end

RSpec::Matchers.define :have_curie do |expected|

  match do |actual|
    expected = expected.stringify_keys
    actual['_links'] and actual['_links']['curies'] and actual['_links']['curies'].any?{ |c| c == expected }
  end

  description do
    "have a curie with options #{expected.inspect}"
  end
end

RSpec::Matchers.define :have_no_curie do

  match do |actual|
    @curies = actual['_links'].try :[], 'curies'
    @curies.nil?
  end

  failure_message do |actual|
    "expected that #{actual} would have no curie, got #{@curies}"
  end

  description do
    "have no curie"
  end
end

RSpec::Matchers.define :have_embedded do |rel,expected|

  match do |actual|
    actual['_embedded'] and actual['_embedded'][rel] and actual['_embedded'][rel] == expected
  end

  failure_message do |actual|
    "expected that #{actual} would have #{expected} with the #{rel} relation"
  end

  description do
    "have the correct embedded resources with the #{rel} relation"
  end
end

RSpec::Matchers.define :hyperlink_to do |expected_rel,expected_href,*args|

  match do |actual|

    @expected_options = args.last.kind_of?(Hash) ? args.last : {}
    
    if @rel_matches = actual['_links'] && (options = actual['_links'][expected_rel.to_s])
      @href_matches = expected_href.to_s == options.delete('href')
      @options_match = @expected_options.stringify_keys == options
    end

    @rel_matches and @href_matches and @options_match
  end

  failure_message do |actual|
    "expected that #{actual} would #{expectations(expected_rel, expected_href, @expected_options).join ' and '}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not #{expectations(expected_rel, expected_href, @expected_options).join ' or '}"
  end

  description do
    "have a relation #{expected_rel} linking to #{expected_href} with options #{@expected_options.inspect}"
  end

  def expectations rel, href, options
    Array.new.tap do |a|
      a << "have a relation #{rel}" unless @rel_matches
      a << "link to #{href}" unless @href_matches
      a << "have options #{options.inspect}" unless @options_match
    end
  end
end

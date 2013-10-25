# Copyright (c) 2012-2013 Lotaris SA
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
require 'spec_helper'

describe RoxHook do
  let(:hooks){ [ CacheHook, StatusData, CacheReportJob, CountDeprecationJob, CountTestsJob ] }

  it "should have all hooks registered", rox: { key: 'c0f472250ab4' } do
    expect(described_class.hooks).to match_array(hooks)
  end

  it "should forward application events to all hooks", rox: { key: '5e0afd9d3056' } do
    hooks.each{ |hook| expect(hook).to receive(:fire).with('event', foo: 'bar') }
    ROXCenter::Application.events.fire 'event', foo: 'bar'
  end
end

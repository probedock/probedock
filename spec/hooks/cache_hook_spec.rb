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

describe "CacheHook" do

  before :each do
    ResqueSpec.reset!
    JsonCache.stub clear: nil
  end

  it "should clear test-related JSON caches when an API payload is received", rox: { key: '52ceabfd82b5' } do
    JsonCache.should_receive(:clear).with do |*args|
      args.collect(&:to_s).should match_array(%w(tag_cloud tests_status latest_projects latest_test_runs))
    end
    CacheHook.fire 'api:payload', double(processed_test_run: double(test_run: double(id: 42)))
  end

  it "should clear the activity and tests_status JSON caches when a test is deprecated", rox: { key: 'dcc24e202f89' } do
    JsonCache.should_receive(:clear).with do |*args|
      args.collect(&:to_s).should match_array(%w(tests_status))
    end
    CacheHook.fire 'test:deprecated', double
  end

  it "should clear the activity and tests_status JSON caches when a test is undeprecated", rox: { key: '8304874e65e8' } do
    JsonCache.should_receive(:clear).with do |*args|
      args.collect(&:to_s).should match_array(%w(tests_status))
    end
    CacheHook.fire 'test:undeprecated', double
  end
end

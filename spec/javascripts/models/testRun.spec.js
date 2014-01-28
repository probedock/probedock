// Copyright (c) 2012-2014 Lotaris SA
//
// This file is part of ROX Center.
//
// ROX Center is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ROX Center is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ROX Center.  If not, see <http://www.gnu.org/licenses/>.
var testRunBase = {
  id : 42,
  results_count : 100,
  passed_results_count : 67,
  inactive_results_count : 8,
  inactive_passed_results_count : 3
};

describe("TestRun", function() {

  var TestRun = App.module('models').TestRun,
      testRun = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    testRun = new TestRun(testRunBase);
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(testRun);
  });

  it("should have API path /api/v1/runs/<id>", function() {
    this.meta = { rox : { key : 'f4175d454c24' } };
    expect(testRun.url()).toBe('/api/v1/runs/42');
  });

  it("should have path /runs/<id>", function() {
    this.meta = { rox : { key : '9ea1cc49e142' } };
    expect(testRun.path()).toBe('/runs/42');
  });

  it("should have a total count of 100", function() {
    this.meta = { rox : { key : '88b9f44038c0' } };
    expect(testRun.totalCount()).toBe(100);
  });

  it("should have a passed count of 64", function() {
    this.meta = { rox : { key : 'f73d07f922a9' } };
    expect(testRun.passedCount()).toBe(64);
  });

  it("should have a failed count of 28", function() {
    this.meta = { rox : { key : '8e2b359fc526' } };
    expect(testRun.failedCount()).toBe(28);
  });

  it("should have an inactive count of 8", function() {
    this.meta = { rox : { key : '5f5f977e7c54' } };
    expect(testRun.inactiveCount()).toBe(8);
  });
});

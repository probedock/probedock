// Copyright (c) 2012-2013 Lotaris SA
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
    expect(testRun.path()).toBe('/en/runs/42');
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

  it("should have a success ratio of 0.72", function() {
    this.meta = { rox : { key : '773d2a143e5e' } };
    expect(testRun.successRatio()).toBe(0.72);
  });

  it("should have a human success ratio of 72%", function() {
    this.meta = { rox : { key : '70ab251a974b' } };
    expect(testRun.humanSuccessRatio()).toBe('72%');
  });

  it("should round human success ratio downward", function() {
    this.meta = { rox : { key : '39945990fc06' } };
    testRun.set({
      results_count : 1000,
      passed_results_count : 654,
      inactive_results_count : 0,
      inactive_passed_results_count : 0
    }, { silent : true });
    expect(testRun.humanSuccessRatio()).toBe('65%');
  });

  it("should round human success ratio upward", function() {
    this.meta = { rox : { key : '60d1cd9be318' } };
    testRun.set({
      results_count : 1000,
      passed_results_count : 435,
      inactive_results_count : 0,
      inactive_passed_results_count : 0
    }, { silent : true });
    expect(testRun.humanSuccessRatio()).toBe('44%');
  });

  it("should have a human success ratio of 99% when over 99.5", function() {
    this.meta = { rox : { key : '021866401494' } };
    testRun.set({
      results_count : 1000,
      passed_results_count : 996,
      inactive_results_count : 495,
      inactive_passed_results_count : 493
    }, { silent : true });
    expect(testRun.humanSuccessRatio()).toBe('99%');
  });
});

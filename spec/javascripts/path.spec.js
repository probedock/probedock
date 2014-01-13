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

describe("Path", function() {

  beforeEach(function() {
    loadFixtures('paths.html');
    Meta._cache = {};
  });

  it("should join path segments", function() {
    this.meta = { rox: { key: '51dea490bfe9' } };
    expect(Path.join('a', 'b', 'c')).toBe('/a/b/c');
    expect(Path.join('/a', '/b/', 'c')).toBe('/a/b/c');
  });

  it("should build a path from the root path", function() {
    this.meta = { rox: { key: 'fb384ea17072' } };
    expect(Path.build('a', 'b')).toBe('/root/a/b');
  });

  it("should return a builder", function() {
    this.meta = { rox: { key: 'aecad84b2492' } };
    expect(Path.builder('a', 'b')()).toBe('/root/a/b');
  });
});

describe("ApiPath", function() {

  beforeEach(function() {
    loadFixtures('paths.html');
    Meta._cache = {};
  });

  it("should build a path from the root of the API", function() {
    this.meta = { rox: { key: 'fc5c9d619cdc' } };
    expect(ApiPath.build('a', 'b')).toBe('/root/api/a/b');
  });

  it("should return a builder", function() {
    this.meta = { rox: { key: '60e3a5a477b5' } };
    expect(ApiPath.builder('a', 'b')()).toBe('/root/api/a/b');
  });
});

describe("PagePath", function() {

  beforeEach(function() {
    loadFixtures('paths.html');
    Meta._cache = {};
  });

  it("should build a path from the home path", function() {
    this.meta = { rox: { key: 'ebd78bcb737a' } };
    expect(PagePath.build('a', 'b')).toBe('/root/home/a/b');
  });

  it("should return a builder", function() {
    this.meta = { rox: { key: '0dd7ef87f0d2' } };
    expect(PagePath.builder('a', 'b')()).toBe('/root/home/a/b');
  });
});

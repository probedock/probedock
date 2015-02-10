// Copyright (c) 2012-2014 Lotaris SA
//
// This file is part of Probe Dock.
//
// Probe Dock is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Probe Dock is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Probe Dock.  If not, see <http://www.gnu.org/licenses/>.

var tagCloudBaseConfig = {
  cloud : [
    { name : 'api', count : 7 },
    { name : 'integration', count : 66 },
    { name : 'unit', count : 42 }
  ]
};

describe("Tag cloud", function() {

  beforeEach(function() {
    SpecHelpers.modules.loadModule('tagCloud', _.clone(tagCloudBaseConfig));
  });

  afterEach(function() {
    SpecHelpers.modules.unloadModule('tagCloud');
  });

  it("should create three tag links", function() {
    this.meta = { rox : { key : 'dac5601fe23e' } };
    expect($('#tagCloudFixture .tagCloud a').length).toBe(3);
  });

  it("should make bigger tag links for most used tags", function() {
    this.meta = { rox : { key : '29d85ac15a03' } };
    expect(cssFontSize($('#tagCloudFixture .tagCloud a:nth-child(2)'), true)).toBeGreaterThan(cssFontSize($('#tagCloudFixture .tagCloud a:nth-child(3)'), true));
    expect(cssFontSize($('#tagCloudFixture .tagCloud a:nth-child(3)'), true)).toBeGreaterThan(cssFontSize($('#tagCloudFixture .tagCloud a:nth-child(1)'), true));
  });
});

describe("Tag cloud with a max size", function() {

  beforeEach(function() {
    var size = tagCloudBaseConfig.cloud.length;
    SpecHelpers.modules.loadModule('tagCloud', _.extend({ size : size, total : size + 2 }, tagCloudBaseConfig));
  });

  afterEach(function() {
    SpecHelpers.modules.unloadModule('tagCloud');
  });

  it("should create three tag links", function() {
    this.meta = { rox : { key : '36fe9d98244c' } };
    expect($('#tagCloudFixture .tagCloud a:not(.all)').length).toBe(3);
  });

  it("should add a link to the full tag cloud if there are more tags", function() {
    this.meta = { rox : { key : '42fe6791d648' } };
    var allLink = $('#tagCloudFixture .tagCloud a.all');
    expect(allLink).toExist();
    expect(allLink.attr('href')).toBe('/tags');
  });
});

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

var buildSampleAutoModule = function(name, moduleOptions) {

  var initializerCalls = [];

  delete App.autoModules[name];
  var sampleAutoModule = App.autoModule(name, function() {

    this.addAutoInitializer(function(options) {
      initializerCalls.push(options);
    });
  }, moduleOptions);

  return { module: sampleAutoModule, initializerCalls: initializerCalls };
};

describe("Auto module", function() {

  var initializerCalls = undefined;

  afterEach(function() {
    SpecHelpers.modules.unloadModule('sample');
  });

  describe("with one matching element", function() {

    beforeEach(function() {
      initializerCalls = buildSampleAutoModule('sample').initializerCalls;
      SpecHelpers.modules.loadModule('sample', { n: 42 });
    });

    it("should be started", function() {
      this.meta = { rox: { key: 'f317ee68a1b9' } };
      expect(initializerCalls.length).toBe(1);
    });

    it("should be started with a region", function() {
      this.meta = { rox: { key: '523eaca2ed26' } };
      expect(initializerCalls[0].region instanceof Backbone.Marionette.Region).toBe(true);
    });

    it("should be started with the configuration of the matching element", function() {
      this.meta = { rox: { key: 'ced1072c771a' } };
      expect(initializerCalls[0].config).toEqual({ n: 42 });
    });
  });

  describe("with the fade option", function() {

    beforeEach(function() {
      initializerCalls = buildSampleAutoModule('sample', { fade: true }).initializerCalls;
      SpecHelpers.modules.loadModule('sample');
    });

    it("should be injected with a fade in region", function() {
      this.meta = { rox: { key: '1d01a16aa294' } };
      expect(initializerCalls[0].region instanceof Backbone.Marionette.FadeInRegion).toBe(true);
    });
  });

  describe("with three matching elements", function() {

    beforeEach(function() {
      initializerCalls = buildSampleAutoModule('sample').initializerCalls;
      SpecHelpers.modules.loadModule('sample', [ { n: 1 }, { n: 2 }, { n: 3 } ]);
    });

    it("should be started three times", function() {
      this.meta = { rox: { key: 'd92c27f44218' } };
      expect(initializerCalls.length).toBe(3);
    });

    it("should be started with the configuration of each matching element", function() {
      this.meta = { rox: { key: 'c099990aa8f6' } };
      expect(initializerCalls[0].config).toEqual({ n: 1 });
      expect(initializerCalls[1].config).toEqual({ n: 2 });
      expect(initializerCalls[2].config).toEqual({ n: 3 });
    });
  });
});

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
var purgeBase = {
  _links: {
  },
  dataType: 'tags',
  numberPurged: 12,
  numberRemaining: 24,
  createdAt: new Date().getTime() - 5000,
  completedAt: new Date().getTime() - 3000
};

describe("Purge", function() {

  var Purge = App.models.Purge,
      purge = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    purge = new Purge(purgeBase);
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(purge);
  });

  it("should use the v1:purges link as its url", function() {
    this.meta = { rox: { key: 'e3d6febdfb09' } };
    spyOn(App.apiRoot, 'fetchHalUrl').andReturn('http://example.com');
    expect(purge.url()).toBe('http://example.com');
    expect(App.apiRoot.fetchHalUrl).toHaveBeenCalledWith([ 'self', 'v1:purges' ]);
  });

  it("should return its translated name", function() {
    this.meta = { rox: { key: '4f3c5fa94a84' } };
    expect(purge.name()).toBe(I18n.t('jst.purge.info.tags.name'));
  });

  it("should indicate whether data can be purged", function() {
    this.meta = { rox: { key: '6b0194ab8f6a' } };
    purge.set({ numberRemaining: 0 });
    expect(purge.isPurgeable()).toBe(false);
    purge.set({ numberRemaining: 42 });
    expect(purge.isPurgeable()).toBe(true);
  });
});

describe("Purges", function() {

  var Purge = App.models.Purge,
      Purges = App.models.Purges,
      purges = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    purges = new Purges();
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(purges);
  });

  function makePurge(options) {
    return _.extend({
      dataType: "tags",
      numberPurged: 2,
      numberRemaining: 0,
      createdAt: new Date().getTime() - 3600000,
      completedAt: new Date().getTime() - 3500000
    }, options);
  }

  function makePurges(purges, options) {
    return _.extend({
      _links: {
        self: {
          href: "http://example.com"
        }
      },
      jobs: 0,
      total: purges.length,
      _embedded: {
        item: purges
      }
    }, options);
  }

  it("should return its self link as its url", function() {
    this.meta = { rox: { key: '1aa10398296e' } };
    purges.set(makePurges([]));
    expect(purges.url()).toBe('http://example.com');
  });

  it("should use the v1:purges link as its url when not saved", function() {
    this.meta = { rox: { key: '46f50cdf5b32' } };
    spyOn(App.apiRoot, 'fetchHalUrl').andReturn('http://example.com/foo');
    expect(purges.url()).toBe('http://example.com/foo');
    expect(App.apiRoot.fetchHalUrl).toHaveBeenCalledWith([ 'self', 'v1:purges' ]);
  });

  it("should use the Purge model", function() {
    this.meta = { rox: { key: '7a49f2b970ce' } };
    expect(getEmbeddedRelation(Purges, 'item').relatedModel).toBe(Purge);
  });

  it("should indicate whether data can be purged", function() {
    this.meta = { rox: { key: '2177eaa0532d' } };

    // no data
    expect(purges.isPurgeable()).toBe(false);

    // no outdated data
    purges.set(makePurges([
      makePurge({ dataType: 'tags', numberPurged: 12, numberRemaining: 0 }),
      makePurge({ dataType: 'tickets', numberPurged: 24, numberRemaining: 0 })
    ]));

    expect(purges.isPurgeable()).toBe(false);

    // outdated data
    purges.set(makePurges([
      makePurge({ dataType: 'tags', numberPurged: 24, numberRemaining: 0 }),
      makePurge({ dataType: 'tickets', numberPurged: 48, numberRemaining: 96 })
    ]));

    expect(purges.isPurgeable()).toBe(true);
  });
});

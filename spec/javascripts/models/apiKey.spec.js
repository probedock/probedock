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

var apiKeyBase = {
  id: '12345678901234567890',
  active: true,
  usageCount: 12,
  lastUsedAt: new Date().getTime(),
  createdAt: new Date().getTime(),
  _links: {
    self: { href: 'http://example.com' }
  }
};

var apiKeysResponse = {
  total: 5,
  _embedded: {
    'item': [
      { id: '12345678901234567890' },
      { id: '23456789012345678901' }
    ]
  }
};

describe("ApiKey", function() {

  var ApiKey = App.models.ApiKey,
      apiKey = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    apiKey = new ApiKey(apiKeyBase);
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(apiKey);
  });

  it("should return its self link when links are given", function() {
    this.meta = { probeDock: { key: 'c1feb59b4b03' } };
    expect(apiKey.url()).toBe('http://example.com');
  });
});

describe("ApiKeys", function() {

  var ApiKey = App.models.ApiKey,
      ApiKeys = App.models.ApiKeys;

  it("should use the ApiKey model", function() {
    this.meta = { probeDock: { key: '7ae87d0e9bc2' } };
    expect(getEmbeddedRelation(ApiKeys, 'item').relatedModel).toBe(ApiKey);
  });
});

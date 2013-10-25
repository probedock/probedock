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
    'v1:api-keys': [
      { id: '12345678901234567890' },
      { id: '23456789012345678901' }
    ]
  }
};

describe("ApiKey", function() {

  var ApiKey = App.module('models').ApiKey,
      apiKey = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    apiKey = new ApiKey(apiKeyBase);
  });

  afterEach(function() {
    Backbone.Relational.store.unregister(apiKey);
  });

  it("should use the identifier as the id", function() {
    this.meta = { rox: { key: '9c5bf30454e5' } };
    expect(apiKey.id).toBe(apiKeyBase.id);
  });

  it("should return the url of the api keys resource", function() {
    this.meta = { rox: { key: 'fe2908390313' } };
    apiKey.unset('_links', { silent: true });
    expect(apiKey.url()).toBe('/api_keys');
  });

  it("should return its self link when links are given", function() {
    this.meta = { rox: { key: 'c1feb59b4b03' } };
    expect(apiKey.url()).toBe('http://example.com');
  });
});

describe("ApiKeyCollection", function() {

  var models = App.module('models'),
      ApiKey = models.ApiKey,
      ApiKeyCollection = models.ApiKeyCollection,
      col = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    col = new ApiKeyCollection();
  });

  it("should use the ApiKey model", function() {
    this.meta = { rox: { key: '7ae87d0e9bc2' } };
    expect(ApiKeyCollection.prototype.model).toBe(ApiKey);
  });

  it("should return the url of the api keys resource", function() {
    this.meta = { rox: { key: '410dab58a254' } };
    expect(col.url()).toBe('/api_keys');
  });

  it("should get api keys from the v1:api-keys property", function() {
    this.meta = { rox: { key: '13d97d48e658' } };
    
    fakeAjaxResponse(function() {
      return col.fetch();
    }, JSON.stringify(apiKeysResponse));

    runs(function() {
      expect(col.models.length).toBe(2);
      expect(col.at(0).attributes).toEqual(apiKeysResponse._embedded['v1:api-keys'][0]);
      expect(col.at(1).attributes).toEqual(apiKeysResponse._embedded['v1:api-keys'][1]);
    });
  });
});

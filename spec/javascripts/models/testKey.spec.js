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

var testKeysResponse = {
  total: 5,
  _embedded: {
    'v1:test-keys': [
      { value: '000000000000' },
      { value: '111111111111' }
    ]
  }
};

describe("TestKeyCollection", function() {

  var models = App.module('models'),
      TestKey = models.TestKey,
      TestKeyCollection = models.TestKeyCollection,
      col = undefined;

  beforeEach(function() {
    loadFixtures('layout.html');
    col = new TestKeyCollection();
  });

  it("should use the TestKey model", function() {
    this.meta = { rox: { key: '48882a47a6a7' } };
    expect(TestKeyCollection.prototype.model).toBe(TestKey);
  });
});

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
describe("TestPayload", function() {

  var now = new Date().getTime(),
      baseTestPayload = {
        id: 42,
        state: 'created',
        receivedAt: now - 3600000,
        contents: '{"foo":"bar"}'
      },
      processingTestPayload = _.extend({}, baseTestPayload, {
        id: 43,
        state: 'processing',
        processingAt: now - 1200000
      }),
      processedTestPayload = _.extend({}, processingTestPayload, {
        id: 44,
        state: 'processed',
        processedAt: now - 30000
      }),
      TestPayload = App.module('models').TestPayload,
      testPayload = null;

  beforeEach(function() {
    loadFixtures('layout.html');
  });

  it("should have API path /payloads/<id>", function() {
    this.meta = { rox: { key: '73171e8d6ec2' } };
    var payload = new TestPayload(baseTestPayload);
    expect(payload.url()).toBe('/payloads/42');
    cleanRelational(payload);
  });

  it("should compute its queue time when available", function() {
    this.meta = { rox: { key: '75c926db01a7' } };
    var payloads = {
      created: new TestPayload(baseTestPayload),
      processing: new TestPayload(processingTestPayload),
      processed: new TestPayload(processedTestPayload)
    };
    expect(payloads.created.queueTime()).toBe(-1);
    expect(payloads.processing.queueTime()).toBe(2400000);
    expect(payloads.processed.queueTime()).toBe(2400000);
    cleanRelational(_.values(payloads));
  });

  it("should compute its processing time when available", function() {
    this.meta = { rox: { key: '78f99ec226a5' } };
    var payloads = {
      created: new TestPayload(baseTestPayload),
      processing: new TestPayload(processingTestPayload),
      processed: new TestPayload(processedTestPayload)
    };
    expect(payloads.created.processingTime()).toBe(-1);
    expect(payloads.processing.processingTime()).toBe(-1);
    expect(payloads.processed.processingTime()).toBe(1170000);
    cleanRelational(_.values(payloads));
  });
});

describe("TestPayloadCollection", function() {

  var models = App.module('models'),
      TestPayload = models.TestPayload,
      TestPayloadCollection = models.TestPayloadCollection;

  it("should use the TestPayload model", function() {
    this.meta = { rox: { key: '2c9d23afce24' } };
    expect(TestPayloadCollection.prototype.model).toBe(TestPayload);
  });
});

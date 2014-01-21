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
describe("Format", function() {

  describe(".duration", function() {

    it("should format durations", function() {
      this.meta = { rox: { key: '64e8f449e8b5' } };
      expect(Format.duration(0)).toBe('0');
      expect(Format.duration(42)).toBe('42ms');
      expect(Format.duration(1000)).toBe('1s');
      expect(Format.duration(12345)).toBe('12s 345ms');
      expect(Format.duration(60000)).toBe('1m');
      expect(Format.duration(62000)).toBe('1m 2s');
      expect(Format.duration(185432)).toBe('3m 5s 432ms');
      expect(Format.duration(360123)).toBe('6m 123ms');
      expect(Format.duration(3600000)).toBe('1h');
      expect(Format.duration(3600234)).toBe('1h 234ms');
      expect(Format.duration(3602000)).toBe('1h 2s');
      expect(Format.duration(4320000)).toBe('1h 12m');
      expect(Format.duration(4434000)).toBe('1h 13m 54s');
      expect(Format.duration(4496023)).toBe('1h 14m 56s 23ms');
      expect(Format.duration(86400000)).toBe('1d');
      expect(Format.duration(90061001)).toBe('1d 1h 1m 1s 1ms');
    });

    it("should omit time units lower than the specified min option", function() {
      this.meta = { rox: { key: 'f6ed7a2fb5d2' } };

      // only display seconds or higher
      expect(Format.duration(0, { min: 's' })).toBe('0');
      expect(Format.duration(432, { min: 's' })).toBe('0');
      expect(Format.duration(1234, { min: 's' })).toBe('1s');
      expect(Format.duration(61000, { min: 's' })).toBe('1m 1s');

      // only display hours or higher
      expect(Format.duration(0, { min: 'h' })).toBe('0');
      expect(Format.duration(123, { min: 'h' })).toBe('0');
      expect(Format.duration(2345, { min: 'h' })).toBe('0');
      expect(Format.duration(66666, { min: 'h' })).toBe('0');
      expect(Format.duration(7200000, { min: 'h' })).toBe('2h');
    });

    it("should throw an error if the min option is not a time unit", function() {
      this.meta = { rox: { key: 'a82c48a4a68c' } };
      try {
        Format.duration(1234, { min: 'foo' });
        this.fail('An error should have been thrown for min option "foo"');
      } catch(e) {
        // success
      }
    });

    it("should shorten to the time unit specified as the shorten option when reached", function() {
      this.meta = { rox: { key: 'aeb61516a83f' } };

      // hide milliseconds once time is at least one second
      expect(Format.duration(0, { shorten: 's' })).toBe('0');
      expect(Format.duration(123, { shorten: 's' })).toBe('123ms');
      expect(Format.duration(2345, { shorten: 's' })).toBe('2s');
      expect(Format.duration(65432, { shorten: 's' })).toBe('1m 5s');
      expect(Format.duration(90061001, { shorten: 's' })).toBe('1d 1h 1m 1s');

      // hide milliseconds once time is at least one second, hide seconds once time is at least one minute
      expect(Format.duration(234, { shorten: 'm' })).toBe('234ms');
      expect(Format.duration(3456, { shorten: 'm' })).toBe('3s');
      expect(Format.duration(65432, { shorten: 'm' })).toBe('1m');
      expect(Format.duration(119999, { shorten: 'm' })).toBe('1m');
      expect(Format.duration(120000, { shorten: 'm' })).toBe('2m');
      expect(Format.duration(90061001, { shorten: 'm' })).toBe('1d 1h 1m');
    });

    it("should throw an error if the shorten option is not a time unit", function() {
      this.meta = { rox: { key: '1427c0884c9a' } };
      try {
        Format.duration(1234, { shorten: 'foo' });
        this.fail("An error should have been thrown for shorten option 'foo'");
      } catch(e) {
        // success
      }
    });

    it("should combine the min and shorten options", function() {
      this.meta = { rox: { key: '5ae66dce56e6' } };
      expect(Format.duration(0, { min: 's', shorten: 'm' })).toBe('0');
      expect(Format.duration(345, { min: 's', shorten: 'm' })).toBe('0');
      expect(Format.duration(1234, { min: 's', shorten: 'm' })).toBe('1s');
      expect(Format.duration(56789, { min: 's', shorten: 'm' })).toBe('56s');
      expect(Format.duration(60000, { min: 's', shorten: 'm' })).toBe('1m');
      expect(Format.duration(65432, { min: 's', shorten: 'm' })).toBe('1m');
      expect(Format.duration(187654, { min: 's', shorten: 'm' })).toBe('3m');
    });
  });
});

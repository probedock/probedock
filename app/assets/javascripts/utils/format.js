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
var Format = {

  truncate : function(string, options) {
    if (options === false) {
      return string;
    }

    var max = options && options.max ? options.max : 30;
    return string.length > max ? string.substring(0, max) + '...' : string;
  },

  number : function(n) {
    return Globalize.format(n, 'n0');
  },

  date : {

    short : function(date) {
      return Globalize.format(date, 'MMM d');
    },

    long : function(date) {
      return Globalize.format(date, 'dddd, MMMM dd, yyyy');
    }
  },

  datetime : {

    short : function(date) {
      return Globalize.format(date, 'MMM dd, HH:mm');
    },

    long : function(date) {
      return Globalize.format(date, 'MMMM dd, yyyy HH:mm');
    },

    full : function(date) {
      return Globalize.format(date, 'dddd, MMMM dd, yyyy HH:mm');
    }
  },

  duration : function(milliseconds, options) {

    if (options && options.min) {
      var duration = Format._findDuration(options.min);
      milliseconds = Math.floor(milliseconds / duration.value) * duration.value;
    }

    if (milliseconds <= 0) {
      return '0';
    }

    if (options && options.shorten) {
      var duration = Format._findDuration(options.shorten);
      var closestDuration = _.find(Format._durations, function(d) {
        return d.value <= duration.value && milliseconds >= d.value;
      });
      if (closestDuration) {
        milliseconds = Math.floor(milliseconds / closestDuration.value) * closestDuration.value;
      }
    }

    return _.inject(Format._durations, function(memo, d) {
      var value = Math.floor(milliseconds / d.value);
      if (value >= 1) {
        milliseconds = milliseconds - value * d.value;
        memo.push(value + d.name);
      }
      return memo;
    }, []).join(' ');
  },

  _findDuration : function(unit) {

    var duration = _.find(Format._durations, function(d) {
      return d.name == unit;
    });

    if (!duration) {
      throw new Error("Unknown duration unit '" + unit + "'.");
    }

    return duration;
  },

  _durations : [
    { name : 'd', value : 86400000 },
    { name : 'h', value : 3600000 },
    { name : 'm', value : 60000 },
    { name : 's', value : 1000 },
    { name : 'ms', value : 1 }
  ]
};

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

var Format = {

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

    if (milliseconds <= 0) {
      return '0';
    }

    if (options && options.format == 'short' && milliseconds >= 1000) {
      milliseconds = Math.round(milliseconds / 1000) * 1000;
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

  _durations : [
    { name : 'd', value : 86400000 },
    { name : 'h', value : 3600000 },
    { name : 'm', value : 60000 },
    { name : 's', value : 1000 },
    { name : 'ms', value : 1 }
  ]
};

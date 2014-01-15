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
var ApiPath = {

  builder : function() {
    var parts = Array.prototype.slice.call(arguments);
    return function() {
      return ApiPath.build.apply(undefined, parts);
    };
  },

  build : function() {
    var parts = Array.prototype.slice.call(arguments);
    parts.splice(0, 0, Meta.get('rootPath'), 'api');
    return Path.join.apply(undefined, parts);
  }
};

var LegacyApiPath = {

  builder : function() {
    var parts = Array.prototype.slice.call(arguments);
    return function() {
      return LegacyApiPath.build.apply(undefined, parts);
    };
  },

  build : function() {
    var parts = Array.prototype.slice.call(arguments);
    parts.splice(0, 0, Meta.get('rootPath'), 'api', 'v1');
    return Path.join.apply(undefined, parts);
  }
};

var Path = {

  builder : function() {
    var parts = Array.prototype.slice.call(arguments);
    return function() {
      return Path.build.apply(undefined, parts);
    };
  },

  build : function() {
    var parts = Array.prototype.slice.call(arguments);
    parts.splice(0, 0, Meta.get('rootPath'));
    return Path.join.apply(undefined, parts);
  },

  join : function() {
    var parts = Array.prototype.slice.call(arguments);
    return _.inject(parts, function(memo, part) {

      part = '' + part;

      var memoEndsWithMatch = memo.match(/\/$/),
          partStartsWithMatch = part.match(/^\//);

      if (!memoEndsWithMatch && !partStartsWithMatch) {
        memo += '/';
      } else if (memoEndsWithMatch && partStartsWithMatch) {
        part = part.replace(/^\//, '');
      }

      return memo + part;
    }, '');
  }
};

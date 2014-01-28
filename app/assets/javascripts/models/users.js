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
App.module('models', function() {

  var User = this.User = Backbone.RelationalModel.extend({

    link: function() {
      return $('<a />').attr('href', this.path()).text(this.get('name'));
    },

    path: function() {
      return Path.build('user', this.get('name'));
    },

    editPath: function() {
      return Path.build('user', this.get('name'), 'edit');
    },

    testsPath: function() {
      return Path.build('tests?' + $.param({ authors: [ this.get('name') ] }));
    }
  });

  var UserCollection = this.UserCollection = Backbone.Collection.extend({

    model: User,
    comparator: function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    }
  });

  var UserTableCollection = this.UserTableCollection = Tableling.Collection.extend({

    url: LegacyApiPath.builder('users'),
    model: User
  });
});

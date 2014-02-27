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

  var User = this.User = this.HalModel.extend({

    halLinks: [ 'self', 'alternate', 'edit' ],

    linkTag: function() {
      return this.link('alternate').tag(this.get('name'));
    }
  });

  var UserCollection = this.UserCollection = this.HalCollection.extend({

    model: User,
    embeddedModels: 'v1:users',
    halUrl: [ { rel: 'v1:users' } ],

    comparator: function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    }
  });
});

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

  this.Purge = this.HalResource.extend({

    halUrl: function() {
      return App.apiRoot.fetchHalUrl([ 'self', 'v1:purges' ]);
    },

    name: function() {
      return I18n.t('jst.purge.info.' + this.get('dataType') + '.name');
    },

    isPurgeable: function() {
      return !!this.get('numberRemaining');
    }
  });

  this.Purges = this.defineHalCollection(this.Purge, {

    halUrl: function() {
      return App.apiRoot.fetchHalUrl([ 'self', 'v1:purges' ]);
    },

    isPurgeable: function() {
      return this.embedded('item').some(function(purge) {
        return purge.isPurgeable();
      });
    }
  });
});

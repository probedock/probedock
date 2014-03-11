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

  this.Test = this.HalResource.extend({

    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:author',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRun',
        relatedModel: 'TestRun'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRunner',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:project',
        relatedModel: 'Project'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:category',
        relatedModel: 'Category'
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tags',
        relatedModel: 'Tag',
        collectionType: 'TagCollection'
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tickets',
        relatedModel: 'Ticket',
        collectionType: 'TicketCollection'
      }
    ],

    isDeprecated: function() {
      return !!this.get('deprecatedAt');
    },

    setDeprecated: function(deprecated, time) {
      if (deprecated) {
        this.set({ deprecatedAt: time });
      } else {
        this.unset('deprecatedAt');
      }
    },

    status: function() {
      if (this.isDeprecated()) {
        return 'deprecated';
      } else if (!this.get('active')) {
        return 'inactive';
      } else {
        return this.get('passing') ? 'passed' : 'failed';
      }
    }
  });

  this.Tests = this.defineHalCollection(this.Test, {

    halUrl: function() {
      return App.apiRoot.fetchHalUrl([ 'self', { name: 'v1:tests', template: this.halUrlTemplate } ]);
    }
  });
});

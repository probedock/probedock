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

  var HalModel = this.HalModel;

  var HalProject = HalModel.extend({

    halLinks: [ 'self', 'alternate' ],

    linkTag: function() {
      return this.link('alternate').tag(this.get('name'));
    }
  });

  var HalTestRun = HalModel.extend({

    halLinks: [ 'self', 'alternate' ]
  });

  var HalCategory = HalModel.extend({

    halLinks: [ 'search' ],

    linkTag: function() {
      return this.link('search').tag(this.get('name'));
    }
  });

  var HalTag = HalModel.extend({

    halLinks: [ 'search' ]
  });

  var HalTicket = HalModel.extend({

    halLinks: [ 'about', 'search' ],

    ticketHref: function() {
      return this.hasLink('about') ? this.link('about').get('href') : this.link('search').get('href');
    }
  });

  this.Test = HalModel.extend({

    halLinks: [ 'self', 'alternate', 'bookmark', 'v1:deprecation', 'v1:testResults', 'v1:projectVersions' ],
    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:author',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRun',
        relatedModel: HalTestRun
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRunner',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'v1:project',
        relatedModel: HalProject
      },
      {
        type: Backbone.HasOne,
        key: 'v1:category',
        relatedModel: HalCategory
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tags',
        relatedModel: HalTag
      },
      {
        type: Backbone.HasMany,
        key: 'v1:tickets',
        relatedModel: HalTicket
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

  this.TestCollection = this.HalCollection.extend({

    model: this.Test,
    embeddedModels: 'v1:tests',
    halUrl: function() {
      return [ { rel: 'v1:tests', template: this.uriTemplateParams || {} } ];
    }
  });
});

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

  var HalUser = HalModel.extend({

    halLinks: [ 'alternate' ],

    linkTag: function() {
      return this.link('alternate').tag(this.get('name'));
    }
  });

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

  var Test = this.Test = HalModel.extend({

    halLinks: [ 'self', 'alternate', 'bookmark', 'v1:deprecation', 'v1:testResults', 'v1:projectVersions' ],
    halEmbedded: [
      {
        type: Backbone.HasOne,
        key: 'v1:author',
        relatedModel: HalUser
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRun',
        relatedModel: HalTestRun
      },
      {
        type: Backbone.HasOne,
        key: 'v1:lastRunner',
        relatedModel: HalUser
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

  var LegacyTest = this.LegacyTest = Backbone.RelationalModel.extend({

    relations: [
      {
        type: Backbone.HasOne,
        key: 'author',
        relatedModel: 'User'
      },
      {
        type: Backbone.HasOne,
        key: 'project',
        relatedModel: 'Project'
      },
      {
        type: Backbone.HasMany,
        key: 'tickets',
        relatedModel: 'Ticket',
        collectionType: 'TicketCollection'
      },
      {
        type : Backbone.HasOne,
        key : 'effective_result',
        relatedModel : 'TestResult'
      }
    ],

    permalink: function(withHost) {
      var path = Path.build('go', 'test') + '?' + $.param({ project: this.get('project').get('apiId'), key: this.get('key') });
      return withHost ? Path.join(window.location.protocol + '//' + window.location.host, path) : path;
    },

    link: function(options) {
      options = _.defaults({}, options, { truncate: false });
      return $('<a />').attr('href', this.path()).text(Format.truncate(this.get('name'), options.truncate));
    },

    apiPath: function() {
      return LegacyApiPath.build('tests', this.toParam());
    },

    path: function() {
      return Path.build('tests', this.toParam());
    },

    toParam: function() {
      return this.get('project').get('apiId') + '-' + this.get('key');
    },

    categoryPath: function() {
      return this.get('category') ? Path.build('tests?' + $.param({ categories: [ this.get('category') ] })) : null;
    },

    categoryLink: function() {
      return this.get('category') ? $('<a />').attr('href', this.categoryPath()).text(this.get('category')) : null;
    },

    isDeprecated: function() {
      return !!this.get('deprecated_at');
    },

    setDeprecated: function(deprecated) {
      this.set({ deprecated_at: deprecated ? new Date().getTime() : null });
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

  var TestTableCollection = this.TestTableCollection = this.HalCollection.extend({

    model: Test,
    embeddedModels: 'v1:tests'
  });
});

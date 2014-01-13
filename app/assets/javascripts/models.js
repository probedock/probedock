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

  var failureColor = $.Color('#ff0000');
  var successColor = $.Color('#008b00');

  var HalModel = Backbone.RelationalModel.extend({

    url: function() {
      var links = this.get('_links');
      return links && links.self ? links.self.href : _.result(this, 'fallbackUrl');
    }
  });

  var HalCollection = Backbone.Collection.extend({

    // TODO: HalCollection should get its URL from API root through relations

    parse: function(response, options) {
      return response['_embedded'] ? response['_embedded'][this.embeddedModels] || [] : [];
    }
  });

  var JobsStatusData = Backbone.RelationalModel.extend({
  });

  var CountStatusData = Backbone.RelationalModel.extend({
  });

  var TestsStatusData = Backbone.RelationalModel.extend({
  });

  var DbStatusData = Backbone.RelationalModel.extend({

    databaseSize: function() {
      return this.get('main') ? Math.round(this.get('main') / 10000) / 100 : undefined;
    },

    humanDatabaseSize: function() {
      var size = this.databaseSize();
      return size && size >= 0 ? size + ' MB' : I18n.t('jst.common.noData')
    },

    cacheSize: function() {
      return this.get('cache') ? Math.round(this.get('cache') / 10000) / 100 : undefined;
    },

    humanCacheSize: function() {
      var size = this.cacheSize();
      return size && size >= 0 ? size + ' MB' : I18n.t('jst.common.noData');
    }
  });

  var GeneralStatusData = this.GeneralStatusData = Backbone.RelationalModel.extend({

    url: Path.builder('data', 'general'),
    relations: [
      {
        type: Backbone.HasOne,
        key: 'jobs',
        relatedModel: JobsStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'count',
        relatedModel: CountStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'db',
        relatedModel: DbStatusData
      },
      {
        type: Backbone.HasOne,
        key: 'tests',
        relatedModel: TestsStatusData
      }
    ]
  });

  var ApiKey = this.ApiKey = HalModel.extend({
    fallbackUrl: Path.builder('api_keys')
  });

  var ApiKeyCollection = this.ApiKeyCollection = HalCollection.extend({

    url: Path.builder('api_keys'),
    model: ApiKey,
    embeddedModels: 'v1:api-keys'
  });

  var TestKey = this.TestKey = Backbone.RelationalModel.extend({
  });

  var TestKeyCollection = this.TestKeyCollection = HalCollection.extend({

    url: ApiPath.builder('test_keys'),
    model: TestKey,
    embeddedModels: 'v1:test-keys'
  });

  var Project = this.Project = Backbone.RelationalModel.extend({

    idAttribute: 'apiId',
    relations: [
      {
        type: Backbone.HasMany,
        key: 'testKeys',
        relatedModel: TestKey,
        collectionType: TestKeyCollection
      }
    ],

    url: function() {
      return this.isNew() ? ApiPath.build('projects') : ApiPath.build('projects', this.get('apiId'));
    },

    path: function() {
      return PagePath.build('projects', this.get('urlToken'));
    },

    link: function() {
      return $('<a />').attr('href', this.path()).text(this.get('name'));
    }
  });

  var ProjectCollection = this.ProjectCollection = Backbone.Collection.extend({
    model: Project
  });

  var ProjectTableCollection = this.ProjectTableCollection = HalCollection.extend({
    
    url: ApiPath.builder('projects'),
    model: Project,
    embeddedModels: 'v1:projects'
  });

  var User = this.User = Backbone.RelationalModel.extend({

    link : function() {
      return $('<a />').attr('href', this.path()).text(this.get('name'));
    },

    path : function() {
      return PagePath.build('user', this.get('name'));
    },

    editPath : function() {
      return PagePath.build('user', this.get('name'), 'edit');
    },

    testsPath : function() {
      return PagePath.build('tests?' + $.param({ authors : [ this.get('name') ] }));
    }
  });

  var UserCollection = this.UserCollection = Backbone.Collection.extend({

    model : User,
    comparator : function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    }
  });

  var UserTableCollection = this.UserTableCollection = Tableling.Collection.extend({

    url : LegacyApiPath.builder('users'),
    model : User
  });

  var Ticket = this.Ticket = Backbone.RelationalModel.extend({

    link : function() {
      return $('<a />').attr('href', this.get('url')).text(this.get('name'));
    }
  });

  var TicketCollection = this.TicketCollection = Backbone.Collection.extend({

    comparator : function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    }
  });

  var Test = this.Test = Backbone.RelationalModel.extend({
    
    relations : [
      {
        type : Backbone.HasOne,
        key : 'author',
        relatedModel : User
      },
      {
        type : Backbone.HasOne,
        key : 'project',
        relatedModel : Project
      },
      {
        type : Backbone.HasMany,
        key : 'tickets',
        relatedModel : Ticket,
        collectionType : TicketCollection
      }
    ],

    name : function(options) {
      if (!options || !options.truncate) {
        return this.get('name');
      }
      var max = options.truncateLength || 40;
      if (this.get('name').length > max && !this.get('name').substring(0, max).match(/\s/)) {
        return this.get('name').substring(0, max) + '...'
      }
      return this.get('name');
    },

    link : function(options) {
      return $('<a />').attr('href', this.path()).text(this.name(options));
    },

    path : function() {
      return PagePath.build('tests', this.get('key'));
    },

    categoryPath : function() {
      return this.get('category') ? PagePath.build('tests?' + $.param({ categories : [ this.get('category') ] })) : null;
    },

    categoryLink : function() {
      return this.get('category') ? $('<a />').attr('href', this.categoryPath()).text(this.get('category')) : null;
    }
  });

  var TestTableCollection = this.TestTableCollection = Tableling.Collection.extend({
    model : Test
  });

  var TestResult = this.TestResult = Backbone.RelationalModel.extend({

    url : function() {
      return LegacyApiPath.build('results', this.get('id'));
    },

    relations : [
      {
        type : Backbone.HasOne,
        key : 'runner',
        relatedModel : User
      },
      {
        type : Backbone.HasOne,
        key : 'test',
        relatedModel : Test
      }
    ],

    dataPath : function() {
      return LegacyApiPath.build('results', this.get('id'));
    },

    humanRunAt : function() {
      return Format.datetime.full(new Date(this.get('run_at')));
    }
  });

  Test.prototype.relations.push({
    type : Backbone.HasOne,
    key : 'effective_result',
    relatedModel : TestResult
  });

  var TestResultTableCollection = this.TestResultTableCollection = Tableling.Collection.extend({
    model : TestResult
  });

  var TestRun = this.TestRun = Backbone.RelationalModel.extend({

    url : function() {
      return LegacyApiPath.build('runs', this.get('id'));
    },

    relations : [
      {
        type : Backbone.HasOne,
        key : 'runner',
        relatedModel : User
      }
    ],

    path : function() {
      return PagePath.build('runs', this.get('id'));
    },

    humanSuccessRatio : function() {

      var ratio = this.successRatio();
      if (ratio >= 0.995 && ratio < 1) {
        ratio = 0.99;
      }

      return Math.round(ratio * 100) + '%';
    },

    successRatio : function() {
      return this.passedAndInactiveCount() / this.get('results_count');
    },

    counts : function() {
      return {
        passed: this.passedCount(),
        failed: this.failedCount(),
        inactive: this.inactiveCount()
      };
    },

    percentages : function(precision) {

      var multiplier = Math.pow(10, precision || 2);

      var passed = Math.round(this.passedCount() * 100 * multiplier / this.totalCount());

      var inactive = Math.round(this.inactiveCount() * 100 * multiplier / this.totalCount());
      if (passed + inactive > 100 * multiplier) {
        inactive = 100 * multiplier - passed;
      }

      var failed = 100 * multiplier - passed - inactive;

      return {
        passed: passed / multiplier,
        inactive: inactive / multiplier,
        failed: failed / multiplier
      };
    },

    passedCount : function(includeInactive) {
      return this.get('passed_results_count') - (includeInactive ? 0 : this.get('inactive_passed_results_count'));
    },

    failedCount : function(includeInactive) {
      return this.get('results_count') - this.get('passed_results_count') - (includeInactive ? 0 : this.get('inactive_results_count') - this.get('inactive_passed_results_count'));
    },

    inactiveCount : function() {
      return this.get('inactive_results_count');
    },

    passedAndInactiveCount : function() {
      return this.get('passed_results_count') + this.get('inactive_results_count') - this.get('inactive_passed_results_count');
    },

    totalCount : function() {
      return this.get('results_count');
    },

    successColor : function() {
      return failureColor.transition(successColor, this.successRatio());
    },

    successDescription : function() {
      return _.reduce(this.counts(), function(memo, value, type) {
        return value ? memo.concat(Format.number(value) + ' ' + I18n.t('jst.testResult.status.' + type)) : memo;
      }, []).join(', ');
    }
  });

  var TestRunCollection = this.TestRunCollection = Tableling.Collection.extend({
    
    url : LegacyApiPath.builder('runs'),
    model : TestRun
  });

  var Link = this.Link = Backbone.RelationalModel.extend({

    url : function() {
      return this.get('id') ? LegacyApiPath.build('links', this.get('id')) : LegacyApiPath.build('links');
    }
  });

  var LinkCollection = this.LinkCollection = Backbone.Collection.extend({

    model : Link,
    comparator : function(a, b) {
      return a.get('name').localeCompare(b.get('name'));
    }
  });
});

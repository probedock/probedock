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

  var Test = this.Test = Backbone.RelationalModel.extend({

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

  var TestTableCollection = this.TestTableCollection = Tableling.Collection.extend({
    model: Test
  });
});

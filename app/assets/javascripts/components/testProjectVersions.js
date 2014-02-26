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
App.module('components', function() {

  var ProjectVersionCollection = App.module('models').ProjectVersionCollection;

  this.TestProjectVersions = Marionette.Controller.extend({

    batchSize: 100,

    initialize: function(options) {
      this.deferreds = [];
      this.collectionClass = this.buildCollectionClass(options.model);
      this.collection = new this.collectionClass();
    },

    load: function() {

      var deferred = $.Deferred();
      if (typeof(this.deferreds) == 'undefined') {
        return deferred.resolve(this.collection);
      }

      if (!this.loadingCollection) {
        App.debug('Loading project versions in batches of ' + this.batchSize + ' for current test...');
        this.loadingCollection = new this.collectionClass();
        this.loadBatch();
      }

      this.deferreds.push(deferred);

      return deferred;
    },

    failLoading: function(xhr) {

      App.debug('Could not load project versions, server responded with unexpected status ' + xhr.status + ' and body ' + xhr.responseText);
      _.each(this.deferreds, function(deferred) {
        deferred.reject();
      });

      delete this.deferreds;
      delete this.loadingCollection;
    },

    finishLoading: function() {

      App.debug('Done loading ' + this.collection.length + ' project versions.');
      _.each(this.deferreds, function(deferred) {
        deferred.resolve(this.collection);
      }, this);

      delete this.deferreds;
      delete this.loadingCollection;
    },

    loadBatch: function(page) {

      page = page || 1;
      if (page >= 10) {
        App.debug('More than ' + (10 * this.batchSize) + ' versions found');
        return this.finishLoading();
      }

      this.loadingCollection.fetch({
        reset: true,
        data: {
          page: page,
          pageSize: this.batchSize,
          sort: [ 'name desc' ]
        }
      }).done(_.bind(this.add, this, page)).fail(_.bind(this.failLoading, this));
    },

    add: function(page, response) {

      var total = response.total;
      App.debug('Loaded ' + this.loadingCollection.length + ' versions (batch ' + page + '/' + Math.ceil(total / this.batchSize) + ').');

      this.collection.add(this.loadingCollection.models);

      if (total > page * this.batchSize) {
        this.loadBatch(page + 1);
      } else {
        this.finishLoading();
      }
    },

    buildCollectionClass: function(test) {
      return ProjectVersionCollection.extend({
        url: test.link('v1:projectVersions').get('href')
      });
    }
  });
});

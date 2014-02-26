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
(function() {

  var models = App.module('models'),
      TestResultCollection = models.TestResultCollection,
      ProjectVersionCollection = models.ProjectVersionCollection;

  var ResultCard = Marionette.ItemView.extend({

    template: false,
    className: 'result',

    initialize: function() {
      this.status = this.model.status();
    },

    onRender: function() {
      this.renderStatus();
      this.renderTooltip();
    },

    renderStatus: function() {
      this.$el.removeClass('passedTest failedTest inactiveTest').addClass(this.status + 'Test');
    },

    renderTooltip: function() {
      this.$el.tooltip({
        title: I18n.t('jst.testWidgets.results.resultDescription.' + (this.model.get('passed') ? 'passed' : 'failed'), {
          time: this.humanRunAt(),
          version: this.model.get('version')
        })
      });
    },

    humanRunAt: function() {
      return Format.datetime.full(new Date(this.model.get('runAt')));
    }
  });

  App.addTestWidget('results', Marionette.CompositeView, {

    itemView: ResultCard,
    itemViewContainer: '.results',
    projectVersionBatchSize: 100,

    ui: {
      form: 'form',
      results: '.results',
      description: '.description',
      sizeSelect: 'form [name="size"]',
      versionSelect: 'form [name="version"]',
      controls: 'form :input'
    },

    events: {
      'change form select': 'updateResults'
    },

    collectionEvents: {
      'reset': 'updateDescription'
    },

    initializeWidget: function() {

      var collectionClass = this.buildCollectionClass();
      this.collection = new collectionClass();

      var projectVersionCollectionClass = this.buildProjectVersionCollectionClass();
      this.projectVersionsCollection = new projectVersionCollectionClass();

      this.listenToOnce(this.collection, 'reset', function() {
        this.ui.results.show();
        this.ui.description.show();
      });
    },

    onRender: function() {
      this.ui.results.hide();
      this.ui.description.hide();
      this.loadProjectVersions();
      this.updateResults();
    },

    setBusy: function(n) {

      var wasBusy = this.busy;

      this.busy = this.busy || 0;
      this.busy += n;

      if (this.busy && !wasBusy) {
        Loader.loading().appendTo(this.ui.form);
      } else if (!this.busy && wasBusy) {
        Loader.clear(this.ui.form);
      }

      this.updateControls();
    },

    loadProjectVersions: function(page) {

      page = page || 1;
      if (page >= 10) {
        App.debug('More than ' + (10 * this.projectVersionBatchSize) + ' versions found');
        return this.updateControls();
      }

      this.setBusy(1);

      this.projectVersionsCollection.fetch({
        reset: true,
        data: {
          page: page,
          pageSize: this.projectVersionBatchSize,
          sort: [ 'name asc' ]
        }
      }).done(_.bind(this.addProjectVersions, this, page));
    },

    addProjectVersions: function(page, response) {

      this.projectVersionsCollection.forEach(function(version) {
        $('<option />').attr('value', version.get('name')).text(version.get('name')).appendTo(this.ui.versionSelect);
      }, this);

      if (response.total > page * this.projectVersionBatchSize) {
        this.loadProjectVersions(page + 1);
      }

      this.setBusy(-1);
    },

    updateResults: function() {

      this.setBusy(1);

      var data = {
        pageSize: parseInt(this.ui.sizeSelect.val(), 10),
        sort: [ 'runAt asc' ]
      };

      var version = this.ui.versionSelect.val();
      if (version.length) {
        data.version = version;
      }

      this.collection.fetch({
        reset: true,
        data: data
      }).complete(_.bind(this.setBusy, this, -1));
    },

    updateControls: function() {
      this.ui.controls.attr('disabled', !!this.busy);
    },

    updateDescription: function() {
      if (this.collection.length == 1) {
        this.ui.description.text(this.t('description', {
          count: 1,
          time: Format.datetime.long(new Date(this.collection.at(0).get('runAt')))
        }));
      } else {
        this.ui.description.text(this.t('description', {
          count: this.collection.length,
          start: Format.datetime.long(new Date(this.collection.at(0).get('runAt'))),
          end: Format.datetime.long(new Date(this.collection.at(this.collection.length - 1).get('runAt')))
        }));
      }
    },

    buildCollectionClass: function() {
      return TestResultCollection.extend({
        url: this.model.link('v1:testResults').get('href')
      });
    },

    buildProjectVersionCollectionClass: function() {
      return ProjectVersionCollection.extend({
        url: this.model.link('v1:projectVersions').get('href')
      });
    }
  });
})();

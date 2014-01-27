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
App.autoModule('appData', function() {

  var models = App.module('models'),
      GeneralStatusData = models.GeneralStatusData;

  var AppDataView = Backbone.Marionette.ItemView.extend({

    template: 'appData',
    ui: {
      environment: 'td.environment',
      databaseSize: 'td.databaseSize',
      cacheSize: 'td.cacheSize',
      localStorageSize: 'td.localStorageSize',
      jobsWorkersRow: 'tr.workers',
      jobsWorkers: 'td.workers',
      jobsWorkingRow: 'tr.working',
      jobsWorking: 'td.working',
      jobsPendingRow: 'tr.pending',
      jobsPending: 'td.pending',
      jobsProcessed: 'td.processed',
      jobsFailedRow: 'tr.failed',
      jobsFailed: 'td.failed',
      users: 'td.users',
      tests: 'td.tests',
      testRuns: 'td.runs',
      testResults: 'td.results',
      jobControls: '.job-controls'
    },

    initialize: function() {
      this.listenTo(this.model, 'change:db', this.renderGeneral);
      this.listenTo(this.model, 'change:count', this.renderCount);
      this.listenTo(this.model, 'change:jobs', this.renderJobs);
    },

    onRender: function() {

      this.renderGeneral();
      this.renderCount();
      this.renderJobs();
      this.renderJobControls();

      App.watchStatus(this, this.updateData, { only: [ 'jobs', 'lastApiPayload', 'lastTestDeprecation' ] });
    },

    updateData: function() {
      App.debug('Fetching new status data...');
      this.model.fetch({
        data: {
          environment: 1,
          db: 1,
          count: 1,
          jobs: 1
        }
      });
    },

    renderGeneral: function() {
      this.ui.environment.text(this.model.get('environment'));
      this.ui.databaseSize.text(this.model.get('db').humanDatabaseSize());
      this.ui.cacheSize.text(this.model.get('db').humanCacheSize());
      this.ui.localStorageSize.text(this.localStorageSize());
    },

    localStorageSize: function() {
      var size = App.storage.size() / 1024;
      return size >= 0 ? (Math.round(size * 100) / 100) + ' KB' : size
    },

    renderJobControls: function() {
      if (!App.admin) {
        return this.ui.jobControls.remove();
      }

      $('<a />').attr('href', Path.builder('resque')).text(I18n.t('jst.appData.resqueLink')).appendTo(this.ui.jobControls);
    },

    renderCount: function() {

      var count = this.model.get('count');
      this.ui.users.text(Format.number(count.get('users')));
      this.ui.tests.text(Format.number(count.get('tests')));
      this.ui.testResults.text(Format.number(count.get('results')));
      this.ui.testRuns.text(Format.number(count.get('runs')));
    },

    renderJobs: function() {

      var jobs = this.model.get('jobs');

      this.ui.jobsWorkers.text(Format.number(jobs.get('workers')));
      this.ui.jobsWorkersRow.removeClass('danger success');
      this.ui.jobsWorkersRow.addClass(jobs.get('workers') > 0 ? 'success' : 'danger');

      this.ui.jobsWorking.text(Format.number(jobs.get('working')));
      this.ui.jobsWorkingRow.removeClass('warning success');
      this.ui.jobsWorkingRow.addClass(jobs.get('working') > 0 ? 'warning' : 'success');

      this.ui.jobsPending.text(Format.number(jobs.get('pending')));
      this.ui.jobsPendingRow.removeClass('warning success');
      this.ui.jobsPendingRow.addClass(jobs.get('pending') > 0 ? 'warning' : 'success');

      this.ui.jobsProcessed.text(Format.number(jobs.get('processed')));

      this.ui.jobsFailed.text(Format.number(jobs.get('failed')));
      this.ui.jobsFailedRow.removeClass('danger success');
      this.ui.jobsFailedRow.addClass(jobs.get('failed') > 0 ? 'danger' : 'success');
    }
  });

  this.addAutoInitializer(function(options) {
    options.region.show(new AppDataView({ model: new GeneralStatusData(options.config) }));
  });
});
